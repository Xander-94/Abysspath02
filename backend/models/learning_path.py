from pydantic import BaseModel, Field, field_validator, validator
from typing import List, Optional, Dict, Any
from uuid import UUID, uuid4
from datetime import datetime

# 基础模型，用于创建时的数据验证
class LearningPathBase(BaseModel):
    title: str = Field(..., description="学习路径标题")
    user_id: UUID = Field(..., description="关联的用户 ID")
    assessment_session_id: Optional[UUID] = Field(None, description="关联的评估会话 ID")
    description: Optional[str] = Field(None, description="路径描述")
    estimated_duration: Optional[str] = Field(None, description="预估完成时间")
    target_goal: Optional[str] = Field(None, description="路径目标")
    metadata: Optional[Dict[str, Any]] = Field(None, description="扩展元数据")

    # 再次确保 Config 类和 json_encoders 正确应用
    model_config = { # Pydantic V2 推荐方式
        "json_encoders": {
            UUID: str
        },
        "from_attributes": True # 替代 orm_mode
    }

# 用于数据库读取的模型，包含数据库生成的字段
class LearningPath(LearningPathBase):
    id: UUID = Field(..., description="路径的唯一 UUID")
    created_at: datetime = Field(..., description="创建时间戳")
    updated_at: datetime = Field(..., description="最后更新时间戳")

    # 配置会继承，无需重复定义除非需要覆盖
    # model_config = {
    #     "json_encoders": { UUID: str },
    #     "from_attributes": True
    # }

# --- PathNode ---
class PathNodeBase(BaseModel):
    id: str = Field(..., description="AI 生成的节点 ID (例如 'python_basics')")
    path_id: UUID = Field(..., description="所属学习路径的 ID")
    label: str = Field(..., description="节点显示名称")
    type: str = Field(..., description="节点类型 ('skill', 'concept', etc.)")
    details: Optional[str] = Field(None, description="节点详细描述")
    estimated_time: Optional[str] = Field(None, description="预估完成时间")
    ui_position: Optional[Dict[str, Any]] = Field(None, description="UI 位置信息 (可选)")
    metadata: Optional[Dict[str, Any]] = Field(None, description="扩展元数据")

    @field_validator('type')
    def validate_node_type(cls, v): # 验证节点类型
        allowed_types = {'skill', 'concept', 'tool', 'project', 'meta_skill', 'influence_skill', 'bridge', 'other'}
        if v not in allowed_types:
            raise ValueError(f"Invalid node type: {v}. Must be one of {allowed_types}")
        return v

    # 添加配置
    model_config = {
        "json_encoders": { UUID: str },
        "from_attributes": True
    }

# PathNode 用于数据库读取 (通常和 Base 一样，除非有 DB 特定字段)
class PathNode(PathNodeBase):
    class Config:
        from_attributes = True

# --- PathEdge ---
class PathEdgeBase(BaseModel):
    path_id: UUID = Field(..., description="所属学习路径的 ID")
    source_node_id: str = Field(..., description="起始节点 ID")
    target_node_id: str = Field(..., description="目标节点 ID")
    relationship_type: Optional[str] = Field(None, description="关系类型 ('dependency', 'sequence', etc.)")
    metadata: Optional[Dict[str, Any]] = Field(None, description="扩展元数据")

    @field_validator('relationship_type')
    def validate_relation_type(cls, v): # 验证关系类型
        if v is None:
            return v
        allowed_types = {'dependency', 'sequence', 'bridge_from', 'bridge_to', 'related', 'bridge', 'parallel'}
        if v not in allowed_types:
            raise ValueError(f"Invalid relation type: {v}. Must be one of {allowed_types}")
        return v

    # 添加配置
    model_config = {
        "json_encoders": { UUID: str },
        "from_attributes": True
    }

# PathEdge 用于数据库读取 (通常和 Base 一样)
class PathEdge(PathEdgeBase):
     class Config:
        from_attributes = True

# --- NodeResource ---
class NodeResourceBase(BaseModel):
    path_id: UUID = Field(..., description="所属学习路径的 ID")
    node_id: UUID # 注意！这里也需要是 UUID，并且需要序列化
    title: str = Field(..., description="资源标题")
    type: str = Field(..., description="资源类型 ('course', 'book', etc.)")
    url: Optional[str] = Field(None, description="资源链接 URL")
    description: Optional[str] = Field(None, description="资源描述")
    metadata: Optional[Dict[str, Any]] = Field(None, description="扩展元数据")

    @field_validator('type')
    def validate_resource_type(cls, v): # 验证资源类型
        allowed_types = {'course', 'book', 'article', 'video', 'tutorial', 'documentation', 'practice', 'community', 'tool', 'podcast', 'other'}
        if v not in allowed_types:
            raise ValueError(f"Invalid resource type: {v}. Must be one of {allowed_types}")
        return v

    # 添加配置
    model_config = {
        "json_encoders": { UUID: str },
        "from_attributes": True
    }

# NodeResource 用于数据库读取，包含 ID
class NodeResource(NodeResourceBase):
    id: UUID = Field(..., description="资源的唯一 UUID")

    class Config:
        from_attributes = True

# --- 用于完整学习路径展示或创建的复合模型 ---
class FullLearningPathData(BaseModel):
    path: LearningPathBase = Field(..., description="学习路径元数据")
    nodes: List[PathNodeBase] = Field(default_factory=list, description="路径中的所有节点")
    edges: List[PathEdgeBase] = Field(default_factory=list, description="节点之间的所有连接")
    resources: Dict[str, List[NodeResourceBase]] = Field(default_factory=dict, description="按节点 ID 分组的资源")

# --- 创建学习路径的请求模型 ---
class LearningPathCreateRequest(BaseModel):
    user_goal: str = Field(..., description="用户的学习目标")
    assessment_session_id: Optional[UUID] = Field(None, description="关联的评估会话 ID")
    user_profile_json: Optional[str] = Field(None, description="用户画像信息的 JSON 字符串")

class FullLearningPathResponse(BaseModel):
    path: LearningPath = Field(..., description="学习路径元数据")
    nodes: List[PathNode] = Field(default_factory=list, description="路径中的所有节点")
    edges: List[PathEdge] = Field(default_factory=list, description="节点之间的所有连接")
    resources: List[NodeResource] = Field(default_factory=list, description="路径中的所有资源")

# --- 对应数据库表的模型 ---

class LearningPathCreateInternal(LearningPathBase):
    user_id: UUID

class LearningPathDB(LearningPathBase):
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True # Pydantic V1 orm_mode
        # from_attributes = True # Pydantic V2

class PathNodeCreateInternal(PathNodeBase):
    id: UUID = Field(default_factory=uuid4) # ID在服务层生成或由DB默认值生成
    path_id: UUID

    # 添加配置
    model_config = {
        "json_encoders": { UUID: str },
        "from_attributes": True
    }

class PathNodeDB(PathNodeBase):
    id: UUID
    path_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True
        # from_attributes = True

class PathEdgeCreateInternal(PathEdgeBase):
    id: UUID = Field(default_factory=uuid4) # ID在服务层生成或由DB默认值生成
    path_id: UUID

    # 添加配置
    model_config = {
        "json_encoders": { UUID: str },
        "from_attributes": True
    }

class PathEdgeDB(PathEdgeBase):
    id: UUID
    path_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True
        # from_attributes = True

class NodeResourceCreateInternal(NodeResourceBase):
    id: UUID = Field(default_factory=uuid4) # ID在服务层生成或由DB默认值生成
    node_id: UUID

    # 添加配置
    model_config = {
        "json_encoders": { UUID: str },
        "from_attributes": True
    }

class NodeResourceDB(NodeResourceBase):
    id: UUID
    node_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True
        # from_attributes = True

# --- AI 输出解析用的模型 (与AI Prompt中的结构对应) ---
class AIParsedResource(BaseModel):
    title: str
    type: str
    url: Optional[str] = None
    description: Optional[str] = None

class AIParsedNode(BaseModel):
    id: str             # AI生成的是字符串ID
    label: str
    type: str
    details: Optional[str] = None
    estimated_time: Optional[str] = None # AI 输出中有这个字段

class AIParsedEdge(BaseModel):
    # 允许 from/to 或 source_node_id/target_node_id
    from_node: Optional[str] = Field(alias='from', default=None)
    to_node: Optional[str] = Field(alias='to', default=None)
    source_node_id: Optional[str] = None
    target_node_id: Optional[str] = None
    relationship_type: Optional[str] = None

    # 校验确保至少有一组来源/目标ID
    @validator('source_node_id', always=True)
    def check_source(cls, v, values):
        if v is None and values.get('from_node') is None:
            raise ValueError('Either source_node_id or from must be provided')
        return v if v is not None else values.get('from_node')

    @validator('target_node_id', always=True)
    def check_target(cls, v, values):
        if v is None and values.get('to_node') is None:
            raise ValueError('Either target_node_id or to must be provided')
        return v if v is not None else values.get('to_node')

class AIParsedLearningPath(BaseModel):
    title: str
    description: Optional[str] = None
    estimated_duration: Optional[str] = None
    target_goal: Optional[str] = None
    nodes: List[AIParsedNode]
    edges: List[AIParsedEdge]
    resources: Dict[str, List[AIParsedResource]] # Key是AI生成的Node ID (str)

class AIOutputWrapper(BaseModel):
    learning_path: AIParsedLearningPath

# --- API 请求/响应模型 ---

# GET /learning-paths/{path_id} 的响应模型 (对应Flutter的FullLearningPathResponse)
class FullLearningPathResponseAPI(BaseModel):
    path: LearningPathDB
    nodes: List[PathNodeDB]
    edges: List[PathEdgeDB]
    resources: List[NodeResourceDB] # 返回扁平列表，前端按需组织

# POST /learning-paths 的请求模型 (对应Flutter的LearningPathCreateRequest)
class LearningPathCreateRequestAPI(BaseModel):
    user_goal: str = Field(..., alias='userGoal') # 添加别名以接受 camelCase
    assessment_session_id: Optional[UUID] = Field(None, alias='assessmentSessionId') # 同样添加别名
    user_profile_json: Optional[str] = Field(None, alias='userProfileJson') # 同样添加别名

# POST /learning-paths 的响应模型 (通常返回创建成功的路径ID或完整路径)
class LearningPathCreateResponseAPI(BaseModel):
    message: str
    learning_path_id: UUID
    # 或者可以返回完整的 FullLearningPathResponseAPI

# GET /learning-paths (列表) 的响应模型
class LearningPathListItemAPI(BaseModel):
    id: UUID
    title: str
    description: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True
        # from_attributes = True 