/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 历史记录数据模型
 * 用于存储单条计算历史记录
 */
export class HistoryItem {
  /** 计算公式（如：1+2） */
  expression: string;
  /** 计算结果（如：3） */
  result: string;
  /** 记录创建时间戳 */
  timestamp: number;

  constructor(expression: string, result: string) {
    this.expression = expression;
    this.result = result;
    this.timestamp = Date.now();
  }
}
