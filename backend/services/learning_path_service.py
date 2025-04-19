from typing import Dict, Any, List, Optional
from datetime import datetime
import uuid
import json
from services.deepseek_service import DeepseekService, DeepseekError
from database import get_supabase_client
import logging
from uuid import UUID, uuid4
from gotrue.errors import AuthApiError  # Assuming supabase client might raise this
from postgrest.exceptions import APIError # Specific error for PostgREST calls
from postgrest import APIResponse # Assume APIResponse is the type returned by execute
from httpx import AsyncClient # Assuming DeepseekService uses httpx
from repositories.learning_path_repository import LearningPathRepository
from models.learning_path import (
    LearningPathCreateRequestAPI,
    FullLearningPathResponseAPI,
    LearningPathListItemAPI,
    LearningPathCreateInternal,
    PathNodeCreateInternal,
    PathEdgeCreateInternal,
    NodeResourceCreateInternal,
    AIOutputWrapper, AIParsedNode, AIParsedEdge, AIParsedResource
)
from models.chat import Message # Import Message model if DeepseekService expects it

logger = logging.getLogger(__name__)

# --- Database Client ---
# Use the actual client retrieval function
# from database import get_supabase_client
# Placeholder for client type hint
# from supabase import Client as SupabaseClient
# --- Mock for Demonstration ---
class SupabaseClientMock: # 模拟 Supabase 客户端
    async def table(self, table_name): print(f"--- Accessing table: {table_name} ---"); return SupabaseTableMock(table_name)
class SupabaseTableMock: # 模拟 Supabase 表
    def __init__(self, name): self.name = name; self._query = ""
    async def insert(self, data, returning="minimal"):
        print(f"Inserting into {self.name}: {json.dumps(data, indent=2, default=str)}"); is_repr = returning == "representation"
        if self.name == 'learning_paths' and is_repr: return APIResponse(data=[{'id': UUID('123e4567-e89b-12d3-a456-426614174000'), **data}], count=1) # Simulate returning representation
        return APIResponse(data=data if isinstance(data, list) else [data], count=len(data) if isinstance(data, list) else 1)
    async def select(self, columns): self._query += f"SELECT {columns}"; return self
    async def eq(self, column, value): self._query += f" WHERE {column}='{value}'"; return self
    async def limit(self, count): self._query += f" LIMIT {count}"; return self
    async def order(self, column, desc=False): self._query += f" ORDER BY {column} {'DESC' if desc else 'ASC'}"; return self
    async def execute(self):
        print(f"Executing query on {self.name}: {self._query}"); self._query = ""
        # Simulate results based on table name
        if self.name == 'learning_paths': return APIResponse(data=[{'id': UUID('123e4567-e89b-12d3-a456-426614174000'), 'title': 'Mock Path', 'user_id': UUID('111e4567-e89b-12d3-a456-426614174111'), 'created_at': '2023-01-01T00:00:00+00:00', 'updated_at': '2023-01-01T00:00:00+00:00'}]*2, count=2) # Simulate list
        if self.name == 'path_nodes': return APIResponse(data=[{'id':'node1', 'path_id': UUID('123e4567-e89b-12d3-a456-426614174000'), 'label':'Node 1', 'type':'skill'}]*3, count=3)
        if self.name == 'path_edges': return APIResponse(data=[{'from_node_id':'node1', 'to_node_id':'node2', 'path_id': UUID('123e4567-e89b-12d3-a456-426614174000')}]*2, count=2)
        if self.name == 'node_resources': return APIResponse(data=[{'id':UUID('789e4567-e89b-12d3-a456-426614174999'), 'node_id':'node1','path_id': UUID('123e4567-e89b-12d3-a456-426614174000'), 'title':'Resource 1', 'type':'article'}]*4, count=4)
        return APIResponse(data=[], count=0) # Default empty
    async def delete(self): print(f"DELETE from {self.name}"); return self # Add delete mock

supabase_client = SupabaseClientMock() # Use the mock

# --- Deepseek Service ---
# from services.deepseek_service import DeepseekService, ChatResponse
# --- Mock for Demonstration ---
class ChatResponseMock: # 模拟 Deepseek 响应
    def __init__(self, content, success=True, error=None): self.content = content; self.success = success; self.error = error
class DeepseekServiceMock: # 模拟 Deepseek 服务
    async def chat(self, messages: List[Dict], is_learning_path: bool = False) -> ChatResponseMock:
        print(f"--- Calling DeepseekService.chat (learning_path={is_learning_path}) ---")
        # Simulate a valid JSON response based on the expected structure
        mock_json = {
            "learning_path": {
                "title": "Mock AI Path", "description": "Desc", "estimated_duration": "1 month", "target_goal": "Learn Mocking",
                "nodes": [{"id": "mock_node_1", "label": "Mock Node 1", "type": "skill", "details": "...", "estimated_time": "1 week"}],
                "edges": [{"from": "mock_node_1", "to": "mock_node_2", "relation_type": "sequence"}],
                "resources": {"mock_node_1": [{"title": "Mock Resource", "type": "article", "url": "http://example.com"}]}
            }
        }
        return ChatResponseMock(content=json.dumps(mock_json))

deepseek_service = DeepseekServiceMock() # Use the mock

# --- Models ---
from models.learning_path import (
    LearningPath, LearningPathBase, PathNode, PathNodeBase, PathEdge, PathEdgeBase,
    NodeResource, NodeResourceBase, FullLearningPathData, FullLearningPathResponse
)
from models.chat import Message # Import Message model if DeepseekService expects it

class LearningPathServiceError(Exception): pass # 自定义服务层错误

class LearningPathService:
    def __init__(
        self,
        repository: LearningPathRepository,
        deepseek_service: DeepseekService
    ):
        self.repository = repository
        self.deepseek_service = deepseek_service
        logger.info("LearningPathService initialized.")

    async def generate_and_save_learning_path(
        self,
        request: LearningPathCreateRequestAPI,
        user_id: UUID
    ) -> UUID:
        """生成学习路径、解析结果并保存到数据库"""
        logger.info(f"Generating learning path for user {user_id} with goal: {request.user_goal}")
        
        # 1. 准备调用 Deepseek 的消息
        #    TODO: 未来可能需要更复杂的逻辑来获取和组合用户画像数据
        #    目前假设 request.user_profile_json 包含所需信息（如果提供）
        prompt_content = f"User Goal: {request.user_goal}\n\n"
        if request.user_profile_json:
            prompt_content += f"User Profile JSON: {request.user_profile_json}"
        else:
            prompt_content += "User Profile JSON: {}" # 提供空对象以满足prompt格式
        
        # messages = [ # 不再需要创建 Message 对象列表
        #     Message(role="user", content=prompt_content)
        # ]

        try:
            # 2. 调用 Deepseek 服务生成学习路径 JSON
            #    注意：传递 prompt_content 字符串给 message 参数
            ai_response = await self.deepseek_service.chat(
                message=prompt_content, # 传递字符串
                is_learning_path=True  # 保持这个标志
            )
            ai_json_str_raw = ai_response.content
            logger.debug(f"Received raw response from Deepseek: {ai_json_str_raw}")
            
            # 清理 AI 返回的字符串，移除可能的 markdown 代码块标记
            ai_json_str = ai_json_str_raw.strip()
            if ai_json_str.startswith("```json"):
                ai_json_str = ai_json_str[len("```json"):].strip()
            if ai_json_str.endswith("```"):
                ai_json_str = ai_json_str[:-len("```")].strip()
                
            logger.debug(f"Cleaned JSON string for parsing: {ai_json_str}")

            # 3. 解析清理后的 JSON
            try:
                 ai_data = json.loads(ai_json_str)
                 # 使用 Pydantic 模型进行验证和解析
                 parsed_output = AIOutputWrapper.parse_obj(ai_data)
                 parsed_path = parsed_output.learning_path
            except json.JSONDecodeError as parse_error:
                 logger.error(f"Failed to parse AI JSON response: {parse_error}")
                 logger.error(f"Problematic JSON string: <<<\n{ai_json_str}\n>>>") # 打印导致错误的字符串
                 raise ValueError(f"AI response format error: {parse_error}") from parse_error
            except Exception as validation_error: # 捕获 Pydantic 或其他验证错误
                 logger.error(f"Failed to validate parsed AI data: {validation_error}")
                 raise ValueError(f"AI response validation error: {validation_error}") from validation_error
            
            logger.info(f"Successfully parsed AI response for path: {parsed_path.title}")

            # 4. 转换数据为数据库模型
            path_id = uuid4()
            ai_node_id_to_uuid: Dict[str, UUID] = {}

            # 创建 LearningPath 记录
            path_db_data = LearningPathCreateInternal(
                user_id=user_id,
                title=parsed_path.title,
                description=parsed_path.description,
                target_goal=parsed_path.target_goal,
                estimated_duration=parsed_path.estimated_duration
                # id 由DB自动生成，如果需要在这里生成也可以
            )

            # 创建 PathNode 记录列表
            nodes_db_data: List[PathNodeCreateInternal] = []
            for node in parsed_path.nodes:
                node_uuid = uuid4()
                ai_node_id_to_uuid[node.id] = node_uuid # 映射AI ID到UUID
                nodes_db_data.append(PathNodeCreateInternal(
                    id=node_uuid,
                    path_id=path_id,
                    label=node.label,
                    type=node.type,
                    details=node.details
                    # position_x/y 暂不处理
                ))
            
            # 创建 PathEdge 记录列表
            edges_db_data: List[PathEdgeCreateInternal] = []
            for edge in parsed_path.edges:
                # 从 AIParsedEdge 获取源和目标 ID (它处理了 alias 和 None)
                source_ai_id = edge.source_node_id # 已经校验过，直接用
                target_ai_id = edge.target_node_id # 已经校验过，直接用
                source_uuid = ai_node_id_to_uuid.get(source_ai_id)
                target_uuid = ai_node_id_to_uuid.get(target_ai_id)

                if source_uuid and target_uuid:
                    # 确保 UUID 被转换为字符串！
                    edge_to_add = PathEdgeCreateInternal(
                        id=uuid4(),
                        path_id=path_id,
                        source_node_id=str(source_uuid), # 确保是 source_node_id 且是 str
                        target_node_id=str(target_uuid), # 确保是 target_node_id 且是 str
                        relationship_type=edge.relationship_type # 使用正确的属性名
                    )
                    edges_db_data.append(edge_to_add)
                else:
                    logger.warning(f"Skipping edge due to missing node UUID mapping: source '{source_ai_id}' -> target '{target_ai_id}'")

            # 创建 NodeResource 记录列表
            resources_db_data: List[NodeResourceCreateInternal] = []
            for ai_node_id, resources_list in parsed_path.resources.items():
                node_uuid = ai_node_id_to_uuid.get(ai_node_id)
                if node_uuid:
                    for resource in resources_list:
                        resources_db_data.append(NodeResourceCreateInternal(
                            id=uuid4(),
                            path_id=path_id,
                            node_id=node_uuid,
                            title=resource.title,
                            type=resource.type,
                            url=resource.url,
                            description=resource.description
                        ))
                else:
                    logger.warning(f"Skipping resources for node {ai_node_id} due to missing UUID mapping.")

            # 5. 调用 Repository 保存到数据库
            #    需要修改 repository 的 create 方法以接受 path_id 并返回它
            #    或者在 repository 内部生成 path_id
            #    当前 repository.create_full_learning_path 返回 LearningPathDB，包含ID
            created_db_path = await self.repository.create_full_learning_path(
                 path_data=path_db_data, # 注意：path_db_data 没有ID，ID是DB生成的
                 nodes_data=[n.copy(update={"path_id": path_id}) for n in nodes_db_data], # 确保 Path ID 关联
                 edges_data=[e.copy(update={"path_id": path_id}) for e in edges_db_data], # 确保 Path ID 关联
                 resources_data=resources_db_data, # Resource 没有 path_id 字段
                 user_goal=request.user_goal # <-- 传递 user_goal
            )
            
            final_path_id = created_db_path.id
            logger.info(f"Successfully created and saved learning path with ID: {final_path_id}")
            return final_path_id

        except DeepseekError as e:
            logger.error(f"Deepseek API error during learning path generation: {e}")
            raise  # Re-raise Deepseek specific error
        except ValueError as e:
             logger.error(f"Data validation or parsing error: {e}")
             raise # Re-raise validation error
        except Exception as e:
            logger.exception(f"Unexpected error generating or saving learning path: {e}")
            raise Exception("Failed to generate or save learning path due to an internal error.") from e

    async def get_learning_path_details(self, path_id: UUID) -> Optional[FullLearningPathResponseAPI]:
        """获取指定学习路径的详细信息"""
        logger.info(f"Fetching details for learning path: {path_id}")
        result = await self.repository.get_full_learning_path_by_id(path_id)
        if result:
            path, nodes, edges, resources = result
            # 将扁平的资源列表转换为 API 响应格式（如果需要按节点分组）
            # 或者直接返回扁平列表，如 FullLearningPathResponseAPI 定义
            return FullLearningPathResponseAPI(
                path=path,
                nodes=nodes,
                edges=edges,
                resources=resources # 返回扁平列表
            )
        logger.warning(f"Learning path details not found for ID: {path_id}")
        return None

    async def get_user_learning_paths(self, user_id: UUID) -> List[LearningPathListItemAPI]:
        """获取用户的所有学习路径列表（简要信息）"""
        logger.info(f"Fetching learning path list for user: {user_id}")
        return await self.repository.list_learning_paths_by_user(user_id)

    async def remove_learning_path(self, path_id: UUID, user_id: UUID) -> bool:
        """删除指定的学习路径 (增加用户ID校验)"""
        logger.info(f"Attempting to delete learning path {path_id} for user {user_id}")
        # 可选：增加权限检查，确保只有路径所有者能删除
        path_details = await self.repository.get_full_learning_path_by_id(path_id)
        if not path_details or path_details[0].user_id != user_id:
             logger.warning(f"User {user_id} unauthorized or path {path_id} not found for deletion.")
             return False # 或者抛出权限错误
        
        deleted = await self.repository.delete_learning_path(path_id)
        if deleted:
            logger.info(f"Successfully deleted learning path {path_id}")
        else:
             logger.error(f"Failed to delete learning path {path_id} in repository.")
        return deleted

    async def save_interaction(self, path_id: str, user_message: str) -> Dict[str, Any]:
        """保存对话交互并更新学习路径"""
        try:
            # 获取AI回复
            response = await self.deepseek_service.chat(message=user_message, is_learning_path=True)
            
            if not response.success:
                return {
                    "interaction": None,
                    "success": False,
                    "error": response.error
                }
            
            # 尝试解析JSON响应
            try:
                path_data = json.loads(response.content)
                # 更新学习路径数据
                await self.supabase.table("learning_path_history").update({
                    "path_data": path_data,
                    "description": path_data.get("description", ""),  # 添加描述字段
                    "updated_at": datetime.utcnow().isoformat()
                }).eq("id", path_id).execute()
            except json.JSONDecodeError:
                logger.warning(f"AI响应不是有效的JSON格式: {response.content}")
            
            # 保存交互记录
            interaction_data = {
                "id": str(uuid.uuid4()),
                "path_id": path_id,
                "user_message": user_message,
                "ai_response": response.content,
                "created_at": datetime.utcnow().isoformat()
            }
            
            result = await self.supabase.table("learning_path_interactions").insert(interaction_data).execute()
            
            return {
                "interaction": result.data[0],
                "success": True,
                "error": None
            }
        except Exception as e:
            logger.error(f"保存学习路径交互失败: {str(e)}")
            return {
                "interaction": None,
                "success": False,
                "error": str(e)
            }

    async def get_learning_path_history(self, user_id: str) -> List[Dict[str, Any]]:
        """获取用户的学习路径历史记录"""
        try:
            result = await self.supabase.table("learning_path_history").select("*").eq("user_id", user_id).order("created_at", desc=True).execute()
            return result.data
        except Exception as e:
            logger.error(f"获取学习路径历史失败: {str(e)}")
            raise Exception(f"获取学习路径历史失败: {str(e)}")

    async def get_learning_path_detail(self, path_id: str) -> Dict[str, Any]:
        """获取学习路径详情，包括对话记录"""
        try:
            # 获取学习路径记录
            result = await self.supabase.table("learning_path_history").select(
                "*",
                count="exact"
            ).eq("id", path_id).execute()
            
            if not result.data:
                return {"error": "学习路径不存在"}
                
            path = result.data[0]
            
            # 获取对话记录并按时间排序
            interactions = await self.supabase.table("learning_path_interactions").select(
                "*"
            ).eq("path_id", path_id).order(
                "created_at", desc=False
            ).execute()
            
            # 将对话记录添加到路径记录中
            path["learning_path_interactions"] = interactions.data if interactions.data else []
            
            return path
            
        except Exception as e:
            logger.error(f"获取学习路径详情失败: {str(e)}")
            return {"error": f"获取学习路径详情失败: {str(e)}"}

    async def complete_learning_path(self, path_id: str) -> Dict[str, Any]:
        """完成学习路径"""
        try:
            update_data = {
                "status": "completed",
                "completed_at": datetime.utcnow().isoformat(),
                "updated_at": datetime.utcnow().isoformat()
            }
            
            result = await self.supabase.table("learning_path_history").update(update_data).eq("id", path_id).execute()
            return result.data[0]
        except Exception as e:
            logger.error(f"完成学习路径失败: {str(e)}")
            raise Exception(f"完成学习路径失败: {str(e)}")

    async def delete_learning_path(self, path_id: str) -> None:
        """删除学习路径及其相关记录"""
        try:
            await self.supabase.table("learning_path_history").delete().eq("id", path_id).execute()
        except Exception as e:
            logger.error(f"删除学习路径失败: {str(e)}")
            raise Exception(f"删除学习路径失败: {str(e)}") 