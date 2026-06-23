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

import { HistoryItem } from '../../viewmodel/HistoryItem';

/**
 * 历史记录管理工具类
 * 负责管理计算历史记录的增删查操作
 */
class HistoryUtil {
  /** 历史记录列表，按时间倒序存储（最新记录在前） */
  private historyList: Array<HistoryItem> = [];

  /** 历史记录最大保存条数 */
  private readonly MAX_HISTORY_SIZE: number = 50;

  /**
   * 添加一条历史记录
   * @param expression 计算公式
   * @param result 计算结果
   */
  addHistory(expression: string, result: string): void {
    // 过滤无效记录
    if (!expression || !result || result === 'NaN' || result === 'error') {
      return;
    }
    // 创建新记录并添加到列表头部
    const newItem = new HistoryItem(expression, result);
    this.historyList.unshift(newItem);
    // 超过最大条数时移除最旧记录
    if (this.historyList.length > this.MAX_HISTORY_SIZE) {
      this.historyList.pop();
    }
  }

  /**
   * 获取全部历史记录
   * @returns 历史记录列表
   */
  getHistoryList(): Array<HistoryItem> {
    return this.historyList;
  }

  /**
   * 清空全部历史记录
   */
  clearHistory(): void {
    this.historyList = [];
  }

  /**
   * 删除指定索引的历史记录
   * @param index 记录索引
   */
  deleteHistoryByIndex(index: number): void {
    if (index >= 0 && index < this.historyList.length) {
      this.historyList.splice(index, 1);
    }
  }

  /**
   * 获取历史记录数量
   * @returns 记录数量
   */
  getHistoryCount(): number {
    return this.historyList.length;
  }

  /**
   * 恢复历史记录（用于迁移恢复）
   * @param historyList 要恢复的历史记录列表
   */
  restoreHistory(historyList: Array<HistoryItem>): void {
    if (!historyList || historyList.length === 0) {
      return;
    }
    // 清空当前历史记录
    this.historyList = [];
    // 恢复历史记录
    for (const item of historyList) {
      this.historyList.push(item);
    }
    // 如果超过最大条数，截断
    if (this.historyList.length > this.MAX_HISTORY_SIZE) {
      this.historyList = this.historyList.slice(0, this.MAX_HISTORY_SIZE);
    }
  }
}

export default new HistoryUtil();
