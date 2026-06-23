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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { UIContext, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { distributedDataObject, commonType } from '@kit.ArkData';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import HistoryUtil from '../common/util/HistoryUtil';
import ResponsiveUtil from '../common/util/ResponsiveUtil';
import { HistoryItem } from '../viewmodel/HistoryItem';

// 日志标签和域
const TAG: string = '[CalculatorContinuation]';
const DOMAIN_NUMBER: number = 0xFF00;

/**
 * 计算器状态数据模型
 * 用于分布式数据对象承载计算器运行状态
 */
class CalculatorState {
  /** 当前输入表达式 */
  inputValue: string | undefined;
  /** 实时计算结果 */
  calValue: string | undefined;
  /** 表达式数组（用于恢复计算状态） */
  expressions: Array<string> | undefined;
  /** 历史记录文件资产（用于文件迁移） */
  historyAsset: commonType.Asset | undefined;
  
  constructor(
    inputValue: string | undefined,
    calValue: string | undefined,
    expressions: Array<string> | undefined,
    historyAsset: commonType.Asset | undefined
  ) {
    this.inputValue = inputValue;
    this.calValue = calValue;
    this.expressions = expressions;
    this.historyAsset = historyAsset;
  }
}

export default class EntryAbility extends UIAbility {
  /** 分布式数据对象实例 */
  private distributedObject: distributedDataObject.DataObject | undefined = undefined;
  /** 本地存储，用于恢复窗口阶段 */
  private storage: LocalStorage = new LocalStorage();

  /**
   * UIAbility创建时回调
   * 应用冷启动或迁移对端冷启动时触发
   */
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(DOMAIN_NUMBER, TAG, '%{public}s', 'Ability onCreate');
    
    // 将 ApplicationContext 存入 AppStorage，供主题管理使用
    AppStorage.setOrCreate('appContext', this.context.getApplicationContext());
    // 存储 UIAbilityContext 供悬浮窗使用
    AppStorage.setOrCreate('uiAbilityContext', this.context);
    
    // 初始化响应式适配工具
    ResponsiveUtil.init(this.context);
    hilog.info(DOMAIN_NUMBER, TAG, '%{public}s', 'ResponsiveUtil initialized');
    
    // 判断是否为迁移启动
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      hilog.info(DOMAIN_NUMBER, TAG, 'Launch from continuation');
      // 处理迁移恢复
      this.handleContinuationRestore(want, launchParam);
    }
  }

  /**
   * UIAbility销毁时回调
   */
  onDestroy() {
    hilog.info(DOMAIN_NUMBER, TAG, '%{public}s', 'Ability onDestroy');
  }

  /**
   * 窗口阶段创建时回调
   * 正常启动时触发
   */
  onWindowStageCreate(windowStage: window.WindowStage) {
    hilog.info(DOMAIN_NUMBER, TAG, '%{public}s', 'Ability onWindowStageCreate');
    
    windowStage.loadContent('pages/HomePage', (err, data) => {
      if (err.code) {
        hilog.error(DOMAIN_NUMBER, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(DOMAIN_NUMBER, TAG, 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');

      let uiContext: UIContext | undefined = windowStage.getMainWindowSync().getUIContext();
      AppStorage.setOrCreate('uiContext', uiContext);
    });
  }

  /**
   * 窗口阶段销毁时回调
   */
  onWindowStageDestroy() {
    hilog.info(DOMAIN_NUMBER, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  /**
   * 窗口阶段恢复时回调
   * 迁移对端恢复时触发，不执行onWindowStageCreate
   */
  onWindowStageRestore(windowStage: window.WindowStage) {
    hilog.info(DOMAIN_NUMBER, TAG, '%{public}s', 'Ability onWindowStageRestore');
    
    // 加载主页面
    windowStage.loadContent('pages/HomePage', (err, data) => {
      if (err.code) {
        hilog.error(DOMAIN_NUMBER, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(DOMAIN_NUMBER, TAG, 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');

      let uiContext: UIContext | undefined = windowStage.getMainWindowSync().getUIContext();
      AppStorage.setOrCreate('uiContext', uiContext);
    });
  }

  /**
   * 应用进入前台时回调
   */
  onForeground() {
    hilog.info(DOMAIN_NUMBER, TAG, '%{public}s', 'Ability onForeground');
  }

  /**
   * 应用进入后台时回调
   */
  onBackground() {
    hilog.info(DOMAIN_NUMBER, TAG, '%{public}s', 'Ability onBackground');
  }

  /**
   * 新Want请求时回调
   * 单实例应用热启动或迁移热启动时触发
   */
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(DOMAIN_NUMBER, TAG, 'Ability onNewWant, launchReason: %{public}d', launchParam.launchReason);
    
    // 判断是否为迁移启动
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      hilog.info(DOMAIN_NUMBER, TAG, 'NewWant from continuation');
      // 处理迁移恢复
      this.handleContinuationRestore(want, launchParam);
    }
  }

  /**
   * 源端迁移数据保存回调
   * 当用户触发迁移时，系统调用此接口保存迁移数据
   * 
   * @param wantParam 迁移参数，用于存储迁移数据
   * @returns 迁移结果：AGREE同意、REJECT拒绝、MISMATCH版本不匹配
   */
  async onContinue(wantParam: Record<string, Object>): Promise<AbilityConstant.OnContinueResult> {
    hilog.info(DOMAIN_NUMBER, TAG, 'onContinue triggered');
    
    try {
      // ========== 步骤1：提取计算器运行状态 ==========
      // 从AppStorage获取当前计算器状态
      const inputValue = AppStorage.get<string>('calculator_inputValue') ?? '';
      const calValue = AppStorage.get<string>('calculator_calValue') ?? '';
      const expressions = AppStorage.get<Array<string>>('calculator_expressions') ?? [];
      
      hilog.info(DOMAIN_NUMBER, TAG, 
        `Calculator state - inputValue: ${inputValue}, calValue: ${calValue}, expressions: ${JSON.stringify(expressions)}`);
      
      // ========== 步骤2：生成sessionId并创建分布式数据对象 ==========
      // 生成唯一的会话ID
      const sessionId: string = distributedDataObject.genSessionId();
      hilog.info(DOMAIN_NUMBER, TAG, `Generated sessionId: ${sessionId}`);
      
      // 将sessionId存入wantParam，传递到对端
      // 注意：使用自定义key避免与系统字段冲突
      wantParam['calculator_sessionId'] = sessionId;
      
      // ========== 步骤3：处理历史记录文件迁移 ==========
      // 获取历史记录列表
      const historyList = HistoryUtil.getHistoryList();
      let historyAsset: commonType.Asset | undefined = undefined;
      
      // 如果有历史记录，将其保存到分布式文件目录
      if (historyList.length > 0) {
        historyAsset = await this.saveHistoryToDistributedDir(historyList);
        if (historyAsset) {
          hilog.info(DOMAIN_NUMBER, TAG, `History asset created: ${JSON.stringify(historyAsset)}`);
        }
      }
      
      // ========== 步骤4：创建分布式数据对象并保存数据 ==========
      // 创建计算器状态数据模型
      const calculatorState = new CalculatorState(inputValue, calValue, expressions, historyAsset);
      
      // 创建分布式数据对象
      this.distributedObject = distributedDataObject.create(this.context, calculatorState);
      
      // 设置sessionId，激活分布式数据对象
      this.distributedObject.setSessionId(sessionId);
      hilog.info(DOMAIN_NUMBER, TAG, `Distributed object activated with sessionId: ${sessionId}`);
      
      // ========== 步骤5：持久化数据到目标设备 ==========
      // 获取目标设备ID
      const targetDevice = wantParam.targetDevice as string;
      hilog.info(DOMAIN_NUMBER, TAG, `Target device: ${targetDevice}`);
      
      // 保存数据到目标设备
      await this.distributedObject.save(targetDevice).then((result: distributedDataObject.SaveSuccessResponse) => {
        hilog.info(DOMAIN_NUMBER, TAG, 
          `Save succeeded - sessionId: ${result.sessionId}, version: ${result.version}, deviceId: ${result.deviceId}`);
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN_NUMBER, TAG, 
          `Save failed - code: ${err.code}, message: ${err.message}`);
        // 不抛出异常，仅记录错误
      });
      
      // 返回同意迁移
      return AbilityConstant.OnContinueResult.AGREE;
      
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN_NUMBER, TAG, 
        `onContinue failed - code: ${err.code}, message: ${err.message}`);
      
      // 发生异常时返回拒绝迁移
      return AbilityConstant.OnContinueResult.REJECT;
    }
  }

  /**
   * 处理迁移恢复
   * 对端设备接收迁移数据并恢复计算器状态
   * 
   * @param want 包含迁移数据的Want
   * @param launchParam 启动参数
   */
  private handleContinuationRestore(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN_NUMBER, TAG, 'handleContinuationRestore');
    
    // 设置迁移状态为活跃，保证迁移连续性
    this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
      hilog.info(DOMAIN_NUMBER, TAG, `setMissionContinueState result: ${JSON.stringify(result)}`);
    });
    
    // 检查want参数是否有效
    if (!want.parameters || !want.parameters['calculator_sessionId']) {
      hilog.error(DOMAIN_NUMBER, TAG, 'Missing sessionId in want parameters');
      return;
    }
    
    // 获取sessionId
    const sessionId = want.parameters['calculator_sessionId'] as string;
    hilog.info(DOMAIN_NUMBER, TAG, `Received sessionId: ${sessionId}`);
    
    // ========== 步骤7：创建空分布式数据对象并加入组网会话 ==========
    // 创建空的计算器状态（属性设为undefined，以便恢复源端数据）
    const emptyState = new CalculatorState(undefined, undefined, undefined, undefined);
    
    // 创建分布式数据对象
    this.distributedObject = distributedDataObject.create(this.context, emptyState);
    
    // ========== 步骤8：监听数据恢复事件 ==========
    // 注册状态监听，等待数据恢复
    this.distributedObject.on('status', 
      (sessionId: string, networkId: string, status: 'online' | 'offline' | 'restored') => {
        hilog.info(DOMAIN_NUMBER, TAG, 
          `Status changed - sessionId: ${sessionId}, networkId: ${networkId}, status: ${status}`);
        
        // 收到restored状态表示数据已恢复
        if (status === 'restored') {
          this.onDataRestored();
        }
      });
    
    // 设置sessionId加入组网
    this.distributedObject.setSessionId(sessionId);
    
    // 触发窗口阶段恢复
    this.context.restoreWindowStage(this.storage);
  }

  /**
   * 数据恢复完成回调
   * 从分布式数据对象中读取恢复的数据并更新UI
   */
  private onDataRestored(): void {
    if (!this.distributedObject) {
      hilog.error(DOMAIN_NUMBER, TAG, 'Distributed object is null');
      return;
    }
    
    hilog.info(DOMAIN_NUMBER, TAG, 'Data restored, updating calculator state');
    
    try {
      // ========== 步骤9：读取恢复的数据并渲染界面 ==========
      // 读取计算器状态
      const inputValue = this.distributedObject['inputValue'] as string;
      const calValue = this.distributedObject['calValue'] as string;
      const expressions = this.distributedObject['expressions'] as Array<string>;
      const historyAsset = this.distributedObject['historyAsset'] as commonType.Asset;
      
      hilog.info(DOMAIN_NUMBER, TAG, 
        `Restored state - inputValue: ${inputValue}, calValue: ${calValue}, expressions: ${JSON.stringify(expressions)}`);
      
      // 将恢复的数据存入AppStorage，供页面使用
      AppStorage.setOrCreate('calculator_inputValue', inputValue ?? '');
      AppStorage.setOrCreate('calculator_calValue', calValue ?? '');
      AppStorage.setOrCreate('calculator_expressions', expressions ?? []);
      
      // 标记为迁移恢复状态，页面将据此恢复UI
      AppStorage.setOrCreate('calculator_isRestored', true);
      
      // 处理历史记录文件恢复
      if (historyAsset && historyAsset.uri) {
        this.restoreHistoryFromDistributedDir(historyAsset);
      }
      
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN_NUMBER, TAG, 
        `Failed to restore data - code: ${err.code}, message: ${err.message}`);
    }
  }

  /**
   * 将历史记录保存到分布式文件目录
   * 
   * @param historyList 历史记录列表
   * @returns 资产对象，用于分布式数据对象迁移
   */
  private async saveHistoryToDistributedDir(historyList: Array<HistoryItem>): Promise<commonType.Asset | undefined> {
    try {
      // 获取分布式文件目录路径
      const distributedDir = this.context.distributedFilesDir;
      const fileName = 'calculator_history.json';
      const filePath = `${distributedDir}/${fileName}`;
      
      hilog.info(DOMAIN_NUMBER, TAG, `Saving history to: ${filePath}`);
      
      // 将历史记录序列化为JSON字符串
      const historyJson = JSON.stringify(historyList);
      
      // 写入文件
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.writeSync(file.fd, historyJson);
      fileIo.closeSync(file.fd);
      
      // 获取文件URI
      const uri = fileUri.getUriFromPath(filePath);
      
      // 获取文件状态信息
      const stat = fileIo.statSync(filePath);
      
      // 创建资产对象
      const asset: commonType.Asset = {
        name: fileName,
        uri: uri,
        path: filePath,
        createTime: stat.ctime.toString(),
        modifyTime: stat.mtime.toString(),
        size: stat.size.toString()
      };
      
      return asset;
      
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN_NUMBER, TAG, 
        `Failed to save history to distributed dir - code: ${err.code}, message: ${err.message}`);
      return undefined;
    }
  }

  /**
   * 从分布式文件目录恢复历史记录
   * 
   * @param historyAsset 历史记录资产对象
   */
  private restoreHistoryFromDistributedDir(historyAsset: commonType.Asset): void {
    try {
      // 获取分布式文件目录路径
      const distributedDir = this.context.distributedFilesDir;
      const filePath = `${distributedDir}/${historyAsset.name}`;
      
      hilog.info(DOMAIN_NUMBER, TAG, `Restoring history from: ${filePath}`);
      
      // 检查文件是否存在
      if (!fileIo.accessSync(filePath)) {
        hilog.warn(DOMAIN_NUMBER, TAG, 'History file not found in distributed dir');
        return;
      }
      
      // 读取文件内容
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
      const buffer = new ArrayBuffer(Number(historyAsset.size));
      fileIo.readSync(file.fd, buffer);
      fileIo.closeSync(file.fd);
      
      // 解码JSON数据
      const decoder = new util.TextDecoder('utf-8');
      const historyJson = decoder.decodeToString(new Uint8Array(buffer));
      
      // 解析历史记录
      const historyList = JSON.parse(historyJson) as Array<HistoryItem>;
      
      // 恢复历史记录到工具类
      HistoryUtil.restoreHistory(historyList);
      
      hilog.info(DOMAIN_NUMBER, TAG, `History restored, count: ${historyList.length}`);
      
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN_NUMBER, TAG, 
        `Failed to restore history from distributed dir - code: ${err.code}, message: ${err.message}`);
    }
  }
}
