# API 接口文档

## 目录
- [认证接口](#认证接口)
- [用户画像接口](#用户画像接口)
- [评估接口](#评估接口)

## 认证接口

### 用户注册
- **接口**: `/auth/register`
- **方法**: `POST`
- **描述**: 用户注册新账号
- **请求参数**:
  ```json
  {
    "email": "string",     // 邮箱地址
    "password": "string",  // 密码
    "name": "string?"      // 用户名（可选）
  }
  ```
- **响应结果**:
  ```json
  {
    "id": "string",           // 用户ID
    "email": "string",        // 邮箱
    "name": "string?",        // 用户名
    "avatar": "string?",      // 头像URL
    "isEmailVerified": false, // 邮箱验证状态
    "createdAt": "string",    // 创建时间
    "updatedAt": "string"     // 更新时间
  }
  ```

### 用户登录
- **接口**: `/auth/login`
- **方法**: `POST`
- **描述**: 用户登录系统
- **请求参数**:
  ```json
  {
    "email": "string",    // 邮箱地址
    "password": "string"  // 密码
  }
  ```
- **响应结果**:
  ```json
  {
    "id": "string",           // 用户ID
    "email": "string",        // 邮箱
    "name": "string?",        // 用户名
    "avatar": "string?",      // 头像URL
    "isEmailVerified": false, // 邮箱验证状态
    "createdAt": "string",    // 创建时间
    "updatedAt": "string",    // 更新时间
    "lastLoginAt": "string"   // 最后登录时间
  }
  ```

### 用户登出
- **接口**: `/auth/logout`
- **方法**: `POST`
- **描述**: 用户退出登录
- **请求参数**: 无
- **响应结果**: 成功状态码

### 重置密码
- **接口**: `/auth/reset-password`
- **方法**: `POST`
- **描述**: 重置用户密码
- **请求参数**:
  ```json
  {
    "email": "string"  // 邮箱地址
  }
  ```
- **响应结果**: 成功状态码

### 更新密码
- **接口**: `/auth/update-password`
- **方法**: `POST`
- **描述**: 更新用户密码
- **请求参数**:
  ```json
  {
    "currentPassword": "string",  // 当前密码
    "newPassword": "string"       // 新密码
  }
  ```
- **响应结果**: 成功状态码

### 验证邮箱
- **接口**: `/auth/verify-email`
- **方法**: `POST`
- **描述**: 验证用户邮箱
- **请求参数**:
  ```json
  {
    "token": "string"  // 验证令牌
  }
  ```
- **响应结果**: 成功状态码

### 重新发送验证邮件
- **接口**: `/auth/resend-verification`
- **方法**: `POST`
- **描述**: 重新发送邮箱验证邮件
- **请求参数**: 无
- **响应结果**: 成功状态码

### 获取当前用户
- **接口**: `/auth/current-user`
- **方法**: `GET`
- **描述**: 获取当前登录用户信息
- **请求参数**: 无
- **响应结果**:
  ```json
  {
    "id": "string",           // 用户ID
    "email": "string",        // 邮箱
    "name": "string?",        // 用户名
    "avatar": "string?",      // 头像URL
    "isEmailVerified": false, // 邮箱验证状态
    "createdAt": "string",    // 创建时间
    "updatedAt": "string",    // 更新时间
    "lastLoginAt": "string"   // 最后登录时间
  }
  ```

### 更新用户资料
- **接口**: `/auth/update-profile`
- **方法**: `POST`
- **描述**: 更新用户个人资料
- **请求参数**:
  ```json
  {
    "name": "string?",   // 用户名（可选）
    "avatar": "string?"  // 头像URL（可选）
  }
  ```
- **响应结果**:
  ```json
  {
    "id": "string",           // 用户ID
    "email": "string",        // 邮箱
    "name": "string?",        // 用户名
    "avatar": "string?",      // 头像URL
    "isEmailVerified": false, // 邮箱验证状态
    "createdAt": "string",    // 创建时间
    "updatedAt": "string"     // 更新时间
  }
  ```

## 用户画像接口

### 获取用户画像
- **接口**: `/profile`
- **方法**: `GET`
- **描述**: 获取用户完整画像信息
- **请求参数**: 无
- **响应结果**:
  ```json
  {
    "hardSkills": {           // 硬核能力
      "string": 0.0          // 能力名称: 熟练度(0-1)
    },
    "metaSkills": {          // 元能力
      "string": 0.0         // 能力名称: 熟练度(0-1)
    },
    "influence": {           // 影响力
      "string": 0.0         // 能力名称: 熟练度(0-1)
    },
    "summary": "string",     // 总结描述
    "skillTypes": [         // 技能种类
      "string"
    ],
    "skillProficiency": {   // 技能熟练度
      "string": 0.0        // 技能名称: 熟练度(0-1)
    },
    "interests": [          // 兴趣爱好
      "string"
    ]
  }
  ```

## 评估接口

### 开始评估
- **接口**: `/assessment/start`
- **方法**: `POST`
- **描述**: 开始新的能力评估
- **请求参数**: 无
- **响应结果**:
  ```json
  {
    "id": "string",           // 评估ID
    "userId": "string",       // 用户ID
    "startTime": "string",    // 开始时间
    "interactions": [],       // 互动记录
    "userProfile": null       // 用户画像（初始为空）
  }
  ```

### 提交回答
- **接口**: `/assessment/submit`
- **方法**: `POST`
- **描述**: 提交评估问题的回答
- **请求参数**:
  ```json
  {
    "assessmentId": "string",  // 评估ID
    "question": "string",      // 问题
    "userResponse": "string"   // 用户回答
  }
  ```
- **响应结果**:
  ```json
  {
    "id": "string",           // 互动ID
    "question": "string",     // 问题
    "userResponse": "string", // 用户回答
    "timestamp": "string",    // 时间戳
    "traits": {              // 特征分析
      "string": 0.0         // 特征名称: 得分(0-1)
    }
  }
  ```

### 获取评估结果
- **接口**: `/assessment/{id}/result`
- **方法**: `GET`
- **描述**: 获取评估的最终结果
- **请求参数**: 无
- **响应结果**:
  ```json
  {
    "id": "string",           // 评估ID
    "userId": "string",       // 用户ID
    "startTime": "string",    // 开始时间
    "interactions": [         // 互动记录列表
      {
        "id": "string",           // 互动ID
        "question": "string",     // 问题
        "userResponse": "string", // 用户回答
        "timestamp": "string",    // 时间戳
        "traits": {              // 特征分析
          "string": 0.0         // 特征名称: 得分(0-1)
        }
      }
    ],
    "userProfile": {         // 用户画像
      "hardSkills": {        // 硬核能力
        "string": 0.0       // 能力名称: 熟练度(0-1)
      },
      "metaSkills": {       // 元能力
        "string": 0.0      // 能力名称: 熟练度(0-1)
      },
      "influence": {        // 影响力
        "string": 0.0      // 能力名称: 熟练度(0-1)
      },
      "summary": "string",  // 总结描述
      "skillTypes": [      // 技能种类
        "string"
      ],
      "skillProficiency": { // 技能熟练度
        "string": 0.0     // 技能名称: 熟练度(0-1)
      },
      "interests": [       // 兴趣爱好
        "string"
      ]
    }
  }
  ```

## 错误响应
所有接口在发生错误时都会返回统一的错误格式：
```json
{
  "error": {
    "code": "string",    // 错误代码
    "message": "string"  // 错误信息
  }
}
```

## 状态码说明
- 200: 请求成功
- 400: 请求参数错误
- 401: 未授权
- 403: 禁止访问
- 404: 资源不存在
- 500: 服务器内部错误 