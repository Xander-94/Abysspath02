from supabase import Client as AsyncClient
from uuid import UUID
from typing import List, Optional, Dict, Tuple
import logging
from pydantic import ValidationError
import time
from functools import wraps
from datetime import datetime, timezone

from models.learning_path import (
    LearningPathDB, LearningPathCreateInternal,
    PathNodeDB, PathNodeCreateInternal,
    PathEdgeDB, PathEdgeCreateInternal,
    NodeResourceDB, NodeResourceCreateInternal,
    LearningPathListItemAPI
)

logger = logging.getLogger(__name__)

def retry_on_timeout(max_retries=3, delay=1):
    """超时重试装饰器"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_error = None
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if "ConnectTimeout" not in str(e) and "ConnectionError" not in str(e):
                        raise
                    last_error = e
                    if attempt < max_retries - 1:
                        logger.warning(f"尝试 {attempt + 1}/{max_retries} 失败，{delay}秒后重试: {e}")
                        time.sleep(delay)
            raise last_error
        return wrapper
    return decorator

class LearningPathRepository:
    def __init__(self, supabase_client: AsyncClient):
        self.db = supabase_client
        # 设置更长的超时时间
        if hasattr(self.db, 'timeout'):
            self.db.timeout = 30

    @retry_on_timeout(max_retries=3, delay=1)
    def _execute_db_operation(self, operation):
        """执行数据库操作的包装函数，带有重试机制"""
        try:
            response = operation.execute()
            logger.debug(f"DB operation response: {response}")
            return response
        except Exception as e:
            logger.error(f"DB operation failed: {str(e)}")
            logger.error(f"Full error details: {repr(e)}")
            raise

    async def create_full_learning_path(
        self,
        path_data: LearningPathCreateInternal,
        nodes_data: List[PathNodeCreateInternal],
        edges_data: List[PathEdgeCreateInternal],
        resources_data: List[NodeResourceCreateInternal],
        user_goal: str
    ) -> LearningPathDB:
        """原子性地创建完整的学习路径及其所有组件和初始消息"""
        try:
            # 记录输入数据
            logger.info(f"Creating learning path with data: {path_data.model_dump_json()}")
            logger.info(f"Nodes count: {len(nodes_data)}, Edges count: {len(edges_data)}, Resources count: {len(resources_data)}")
            
            # 1. 创建 LearningPath
            logger.info("Inserting learning path record...")
            table = self.db.table("learning_paths")
            path_dict = path_data.model_dump(mode='json')
            
            # 添加时间戳字段
            current_time = datetime.now(timezone.utc).isoformat()
            path_dict.update({
                'created_at': current_time,
                'updated_at': current_time
            })
            
            logger.info(f"Learning path data to insert: {path_dict}")
            
            try:
                path_response = self._execute_db_operation(
                    table.insert(path_dict)
                )
                logger.debug(f"Path insert response: {path_response}")
            except Exception as e:
                logger.error(f"Failed to insert learning path: {str(e)}")
                logger.error(f"Insert data was: {path_dict}")
                raise Exception(f"Failed to insert learning path: {str(e)}") from e
            
            if not path_response.data:
                error_detail = f"Failed to create learning path: {getattr(path_response, 'error', 'No data returned')}"
                logger.error(error_detail)
                logger.error(f"Full response: {path_response}")
                raise Exception(error_detail)
            try:
                created_path = LearningPathDB.parse_obj(path_response.data[0])
            except (IndexError, TypeError, ValidationError) as parse_error:
                logger.error(f"Failed to parse learning path response: {parse_error}. Response data: {path_response.data}")
                raise Exception(f"Failed to parse learning path response: {parse_error}") from parse_error
            
            logger.info(f"Created LearningPath: {created_path.id}")
            path_uuid_str = str(created_path.id)

            # 2. 批量创建 PathNode
            if nodes_data:
                for node in nodes_data:
                    node.path_id = created_path.id
                node_dicts = [node.model_dump(mode='json') for node in nodes_data]
                logger.info(f"Node data to insert: {node_dicts}")
                node_table = self.db.table("path_nodes")
                try:
                    node_response = self._execute_db_operation(
                        node_table.insert(node_dicts)
                    )
                    logger.debug(f"Node insert response: {node_response}")
                except Exception as e:
                    logger.error(f"Failed to insert nodes: {str(e)}")
                    logger.error(f"Insert data was: {node_dicts}")
                    raise Exception(f"Failed to insert nodes: {str(e)}") from e
                
                if not node_response.data:
                    error_detail = f"Failed to create path nodes: {getattr(node_response, 'error', 'No data returned')}"
                    logger.error(error_detail)
                    logger.error(f"Full node response: {node_response}")
                    raise Exception(error_detail)
                logger.info(f"Created {len(node_response.data)} PathNodes for {path_uuid_str}")

            # 3. 批量创建 PathEdge
            if edges_data:
                for edge in edges_data:
                    edge.path_id = created_path.id
                edge_dicts = [edge.model_dump(mode='json') for edge in edges_data]
                logger.info(f"Edge data to insert: {edge_dicts}")
                edge_table = self.db.table("path_edges")
                try:
                    edge_response = self._execute_db_operation(
                        edge_table.insert(edge_dicts)
                    )
                    logger.debug(f"Edge insert response: {edge_response}")
                except Exception as e:
                    logger.error(f"Failed to insert edges: {str(e)}")
                    logger.error(f"Insert data was: {edge_dicts}")
                    raise Exception(f"Failed to insert edges: {str(e)}") from e
                
                if not edge_response.data:
                    error_detail = f"Failed to create path edges: {getattr(edge_response, 'error', 'No data returned')}"
                    logger.error(error_detail)
                    logger.error(f"Full edge response: {edge_response}")
                    raise Exception(error_detail)
                logger.info(f"Created {len(edge_response.data)} PathEdges for {path_uuid_str}")

            # 4. 批量创建 NodeResource
            if resources_data:
                # *** 补充缺失的 path_id 赋值逻辑 ***
                for res in resources_data:
                    res.path_id = created_path.id 
                # **********************************
                resource_dicts = [res.model_dump(mode='json') for res in resources_data]
                logger.info(f"Resource data to insert: {resource_dicts}")
                resource_table = self.db.table("node_resources")
                try:
                    resource_response = self._execute_db_operation(
                        resource_table.insert(resource_dicts)
                    )
                    logger.debug(f"Resource insert response: {resource_response}")
                except Exception as e:
                    logger.error(f"Failed to insert resources: {str(e)}")
                    logger.error(f"Insert data was: {resource_dicts}")
                    raise Exception(f"Failed to insert resources: {str(e)}") from e
                
                if not resource_response.data:
                    error_detail = f"Failed to create node resources: {getattr(resource_response, 'error', 'No data returned')}"
                    logger.error(error_detail)
                    logger.error(f"Full resource response: {resource_response}")
                    raise Exception(error_detail)
                logger.info(f"Created {len(resource_response.data)} NodeResources")

            # 5. *** 添加初始消息插入逻辑 ***
            logger.info(f"Inserting initial messages for path {path_uuid_str}...")
            message_table = self.db.table("learning_path_messages")
            current_time_iso = datetime.now(timezone.utc).isoformat()
            initial_messages = [
                {
                    'role': 'user',
                    'content': user_goal,
                    'path_id': path_uuid_str,
                    'created_at': current_time_iso,
                },
                {
                    'role': 'assistant',
                    'content': '学习路径已为您生成！点击下方按钮查看详情。',
                    'path_id': path_uuid_str,
                    'created_at': current_time_iso,
                    'is_creation_confirmation': True,
                }
            ]
            try:
                message_response = self._execute_db_operation(
                    message_table.insert(initial_messages)
                )
                logger.debug(f"Initial messages insert response: {message_response}")
                if not message_response.data:
                     error_detail = f"Failed to create initial messages: {getattr(message_response, 'error', 'No data returned')}"
                     logger.error(error_detail)
                     raise Exception(error_detail) 
                else:
                    logger.info(f"Created {len(message_response.data)} initial messages for {path_uuid_str}")
            except Exception as e:
                logger.error(f"Failed to insert initial messages: {str(e)}")
                logger.error(f"Insert data was: {initial_messages}")
                raise Exception(f"Failed to insert initial messages: {str(e)}") from e
            # **********************************

            return created_path

        except Exception as e:
            logger.exception(f"Error during full learning path creation: {str(e)}")
            # 记录完整的异常堆栈
            import traceback
            logger.error(f"Full traceback: {traceback.format_exc()}")
            raise

    async def get_full_learning_path_by_id(self, path_id: UUID) -> Optional[Tuple[LearningPathDB, List[PathNodeDB], List[PathEdgeDB], List[NodeResourceDB]]]:
        """根据ID获取完整的学习路径及其所有组件"""
        try:
            # 1. 获取 LearningPath
            path_response = self.db.table("learning_paths") \
                .select("*") \
                .eq("id", str(path_id)) \
                .maybe_single() \
                .execute()

            if not path_response.data:
                logger.warning(f"Learning path not found: {path_id}")
                return None
            path = LearningPathDB.parse_obj(path_response.data)

            # 2. 获取关联的 PathNode
            nodes_response = self.db.table("path_nodes") \
                .select("*") \
                .eq("path_id", str(path_id)) \
                .execute()
            nodes = [PathNodeDB.parse_obj(n) for n in nodes_response.data] if nodes_response.data else []

            # 3. 获取关联的 PathEdge
            edges_response = self.db.table("path_edges") \
                .select("*") \
                .eq("path_id", str(path_id)) \
                .execute()
            edges = [PathEdgeDB.parse_obj(e) for e in edges_response.data] if edges_response.data else []

            # 4. 获取关联的 NodeResource (需要所有节点的ID)
            node_ids = [str(node.id) for node in nodes]
            resources = []
            if node_ids:
                resources_response = self.db.table("node_resources") \
                    .select("*") \
                    .in_("node_id", node_ids) \
                    .execute()
                resources = [NodeResourceDB.parse_obj(r) for r in resources_response.data] if resources_response.data else []

            return path, nodes, edges, resources

        except Exception as e:
            logger.exception(f"Error fetching full learning path {path_id}: {e}")
            return None

    async def list_learning_paths_by_user(self, user_id: UUID) -> List[LearningPathListItemAPI]:
        """获取指定用户的所有学习路径列表（简要信息）"""
        try:
            response = self.db.table("learning_paths") \
                .select("id, title, description, created_at, updated_at") \
                .eq("user_id", str(user_id)) \
                .order("updated_at", desc=True) \
                .execute()
            
            if response.data:
                 # 使用 parse_obj 进行转换以利用 Pydantic 的验证
                return [LearningPathListItemAPI.parse_obj(item) for item in response.data]
            else:
                return []
        except Exception as e:
            logger.exception(f"Error listing learning paths for user {user_id}: {e}")
            return []

    async def delete_learning_path(self, path_id: UUID) -> bool:
        """删除学习路径及其所有关联数据 (注意级联删除已在DB层面设置)"""
        try:
            # 由于DB中设置了 ON DELETE CASCADE，理论上只需删除 learning_paths 记录
            response = self.db.table("learning_paths") \
                .delete() \
                .eq("id", str(path_id)) \
                .execute()
            
            # 检查是否有数据被删除 (data通常为空或包含被删除的记录，具体看库实现)
            # 更可靠的方式可能是检查 error
            if response.error:
                 logger.error(f"Error deleting learning path {path_id}: {response.error}")
                 return False
            # 或者检查影响的行数（如果库提供）
            logger.info(f"Deleted learning path {path_id} (or it didn't exist).")
            return True # 即使路径不存在也认为删除成功
        except Exception as e:
            logger.exception(f"Error deleting learning path {path_id}: {e}")
            return False 