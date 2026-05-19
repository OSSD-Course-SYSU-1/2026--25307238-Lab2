import { HistoryItem } from "@bundle:com.example.simplecalculator/entry/ets/viewmodel/HistoryItem";
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
}
export default new HistoryUtil();
