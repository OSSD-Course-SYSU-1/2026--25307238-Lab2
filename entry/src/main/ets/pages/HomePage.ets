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

import Logger from '../common/util/Logger';
import CalculateUtil from '../common/util/CalculateUtil';
import CheckEmptyUtil from '../common/util/CheckEmptyUtil';
import HistoryUtil from '../common/util/HistoryUtil';
import ThemeUtil, { ThemeMode } from '../common/util/ThemeUtil';
import ResponsiveUtil, { Breakpoint, Orientation, LayoutMode, ResponsiveConfig, ResponsiveSize } from '../common/util/ResponsiveUtil';
import keysModel from '../viewmodel/PresskeysViewModel';
import { PressKeysBean } from '../viewmodel/PressKeysItem';
import { HistoryItem } from '../viewmodel/HistoryItem';
import { CommonConstants, Symbol } from '../common/constants/CommonConstants';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct HomePage {
  @State inputValue: string = '';
  @State calValue: string = '';
  private expressions: Array<string> = [];
  /** 历史记录弹窗显示状态 */
  @State isHistoryDialogShow: boolean = false;
  /** 历史记录列表（用于UI刷新） */
  @State historyList: Array<HistoryItem> = [];
  /** 当前主题模式（监听 AppStorage 变化） */
  @StorageLink('currentThemeMode') currentThemeMode: number = ThemeMode.LIGHT;
  /** 随机数下限 */
  @State randomMin: string = '';
  /** 随机数上限 */
  @State randomMax: string = '';
  /** 随机数错误提示 */
  @State randomError: string = '';
  
  /** 响应式配置（监听 AppStorage 变化） */
  @StorageLink('responsiveConfig') @Watch('onResponsiveConfigChange') responsiveConfig: ResponsiveConfig = {
    minWidth: 280,
    breakpoint: Breakpoint.SM,
    orientation: Orientation.PORTRAIT,
    layoutMode: LayoutMode.COMPACT,
    screenWidth: 360,
    screenHeight: 640
  };
  /** 响应式尺寸（根据配置计算） */
  @State responsiveSize: ResponsiveSize | null = null;

  /** 主题管理键名 */
  private static readonly THEME_KEY: string = 'currentThemeMode';

  /** 页面即将显示时初始化主题和响应式配置 */
  aboutToAppear(): void {
    // 初始化主题管理
    ThemeUtil.init();
    
    // 初始化响应式尺寸
    this.responsiveSize = ResponsiveUtil.getResponsiveSize();
    
    // ========== 迁移恢复处理 ==========
    // 检查是否为迁移恢复状态
    const isRestored = AppStorage.get<boolean>('calculator_isRestored');
    if (isRestored) {
      // 从AppStorage恢复计算器状态
      const restoredInputValue = AppStorage.get<string>('calculator_inputValue');
      const restoredCalValue = AppStorage.get<string>('calculator_calValue');
      const restoredExpressions = AppStorage.get<Array<string>>('calculator_expressions');
      
      if (restoredInputValue !== undefined) {
        this.inputValue = restoredInputValue;
      }
      if (restoredCalValue !== undefined) {
        this.calValue = restoredCalValue;
      }
      if (restoredExpressions !== undefined && restoredExpressions.length > 0) {
        this.expressions = [...restoredExpressions];
      }
      
      // 清除迁移恢复标记
      AppStorage.setOrCreate('calculator_isRestored', false);
      
      // 刷新历史记录列表
      this.historyList = HistoryUtil.getHistoryList();
      
      Logger.info('HomePage', 'Calculator state restored from continuation');
    }
  }
  
  /** 监听响应式配置变化，实时更新尺寸 */
  onResponsiveConfigChange(): void {
    // 当屏幕尺寸变化时，更新响应式尺寸
    this.responsiveSize = ResponsiveUtil.getResponsiveSize();
    Logger.info('HomePage', `Responsive config changed: ${this.responsiveConfig.breakpoint}, ${this.responsiveConfig.orientation}`);
  }

  build() {
    Column() {
      // 极窄屏幕友好提示
      if (this.responsiveConfig.screenWidth < 280) {
        this.buildNarrowScreenTip();
      } else {
        // 根据布局模式选择不同的布局
        if (this.responsiveConfig.layoutMode === LayoutMode.COMPACT) {
          // 小屏：单列紧凑布局
          this.buildCompactLayout();
        } else if (this.responsiveConfig.layoutMode === LayoutMode.STANDARD) {
          // 中屏：标准布局（横屏双列，竖屏单列）
          if (this.responsiveConfig.orientation === Orientation.LANDSCAPE) {
            this.buildExpandedLayout();
          } else {
            this.buildCompactLayout();
          }
        } else {
          // 大屏/超大屏：扩展布局（双列）
          this.buildExpandedLayout();
        }
      }
    }
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.column_back_color'))
    .bindSheet($$this.isHistoryDialogShow, this.historySheetBuilder(), {
      height: this.responsiveSize ? `${this.responsiveSize.inputHeight * 5}vp` : '450vp',
      backgroundColor: $r('app.color.history_dialog_bg'),
      dragBar: true,
      showClose: true
    })
  }

  /**
   * 极窄屏幕友好提示
   */
  @Builder
  buildNarrowScreenTip() {
    Column() {
      Column() {
        Text('⚠️')
          .fontSize(48)
          .margin({ bottom: 16 })
        
        Text('屏幕宽度不足')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_color'))
          .margin({ bottom: 8 })
        
        Text('当前屏幕宽度过窄，可能影响正常使用。请尝试横屏或使用更大屏幕设备。')
          .fontSize(14)
          .fontColor($r('app.color.text_color'))
          .opacity(0.7)
          .textAlign(TextAlign.Center)
          .width('80%')
          .margin({ bottom: 24 })
        
        Button('继续使用')
          .width('60%')
          .height(44)
          .fontSize(16)
          .backgroundColor($r('app.color.history_button_color'))
          .fontColor(Color.White)
          .borderRadius(22)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 单列紧凑布局（小屏）
   */
  @Builder
  buildCompactLayout() {
    Column() {
      // 顶部按钮区域
      this.buildTopBar();
      
      // 随机数模块（仅在大屏显示）
      if (this.responsiveConfig.layoutMode !== LayoutMode.COMPACT) {
        this.buildRandomModule();
      }
      
      // 显示区域
      this.buildDisplayArea();
      
      // 按键区域
      this.buildKeypad();
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 扩展布局（大屏双列）
   */
  @Builder
  buildExpandedLayout() {
    Row() {
      // 左侧：计算器主体
      Column() {
        // 顶部按钮区域
        this.buildTopBar();
        
        // 随机数模块
        this.buildRandomModule();
        
        // 显示区域
        this.buildDisplayArea();
        
        // 按键区域
        this.buildKeypad();
      }
      .width('60%')
      .height('100%')
      
      // 右侧：历史记录区域
      Column() {
        this.buildHistoryPanel();
      }
      .width('40%')
      .height('100%')
      .backgroundColor($r('app.color.history_item_bg'))
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 顶部按钮区域
   */
  @Builder
  buildTopBar() {
    Row() {
      // 主题切换按钮
      Button({ type: ButtonType.Circle }) {
        if (this.currentThemeMode === ThemeMode.LIGHT) {
          Text('🌙')
            .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.8 : 20)
        } else {
          Text('☀️')
            .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.8 : 20)
        }
      }
      .width(this.responsiveSize ? this.responsiveSize.buttonHeight : 50)
      .height(this.responsiveSize ? this.responsiveSize.buttonHeight : 50)
      .backgroundColor($r('app.color.theme_button_color'))
      .onClick(() => {
        ThemeUtil.toggleTheme();
      })

      Blank()

      // 历史记录按钮（仅在小屏显示）
      if (this.responsiveConfig.layoutMode === LayoutMode.COMPACT ||
          this.responsiveConfig.layoutMode === LayoutMode.STANDARD) {
        Button({ type: ButtonType.Circle }) {
          Text($r('app.string.history_button'))
            .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.5 : 12)
            .fontColor($r('app.color.text_color'))
        }
        .width(this.responsiveSize ? this.responsiveSize.buttonHeight : 50)
        .height(this.responsiveSize ? this.responsiveSize.buttonHeight : 50)
        .backgroundColor($r('app.color.history_button_color'))
        .onClick(() => {
          this.historyList = HistoryUtil.getHistoryList();
          this.isHistoryDialogShow = true;
        })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: this.responsiveSize ? this.responsiveSize.margin : 22,
      right: this.responsiveSize ? this.responsiveSize.margin : 22,
      top: 20
    })
  }

  /**
   * 随机数模块
   */
  @Builder
  buildRandomModule() {
    Column() {
      Row({ space: this.responsiveSize ? this.responsiveSize.buttonSpacing : 8 }) {
        Text('随机数区间：')
          .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.7 : 14)
          .fontColor($r('app.color.text_color'))
        
        TextInput({ placeholder: '下限', text: this.randomMin })
          .width(this.responsiveSize ? this.responsiveSize.buttonWidth * 1.2 : 80)
          .height(this.responsiveSize ? this.responsiveSize.buttonHeight * 0.6 : 36)
          .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.7 : 14)
          .type(InputType.Number)
          .textAlign(TextAlign.Center)
          .onChange((value: string) => {
            this.randomMin = value;
            this.randomError = '';
          })
        
        Text('~')
          .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.8 : 16)
          .fontColor($r('app.color.text_color'))
          .fontWeight(FontWeight.Bold)
        
        TextInput({ placeholder: '上限', text: this.randomMax })
          .width(this.responsiveSize ? this.responsiveSize.buttonWidth * 1.2 : 80)
          .height(this.responsiveSize ? this.responsiveSize.buttonHeight * 0.6 : 36)
          .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.7 : 14)
          .type(InputType.Number)
          .textAlign(TextAlign.Center)
          .onChange((value: string) => {
            this.randomMax = value;
            this.randomError = '';
          })
        
        Button('生成随机数')
          .width(this.responsiveSize ? this.responsiveSize.buttonWidth * 1.3 : 90)
          .height(this.responsiveSize ? this.responsiveSize.buttonHeight * 0.6 : 36)
          .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.7 : 14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .borderRadius(this.responsiveSize ? this.responsiveSize.buttonRadius * 0.5 : 6)
          .onClick(() => {
            this.generateRandomNumber();
          })
      }
      .width('100%')
      .height(this.responsiveSize ? this.responsiveSize.buttonHeight * 0.6 : 36)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      
      if (this.randomError) {
        Row() {
          Text('⚠ ' + this.randomError)
            .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.6 : 12)
            .fontColor('#FF4444')
        }
        .width('100%')
        .height(20)
        .justifyContent(FlexAlign.Center)
        .margin({ top: 4 })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .margin({
      left: this.responsiveSize ? this.responsiveSize.margin : 22,
      right: this.responsiveSize ? this.responsiveSize.margin : 22,
      top: 12
    })
    .padding({
      left: this.responsiveSize ? this.responsiveSize.padding : 12,
      right: this.responsiveSize ? this.responsiveSize.padding : 12,
      top: 10,
      bottom: 10
    })
    .backgroundColor($r('app.color.history_item_bg'))
    .borderRadius(this.responsiveSize ? this.responsiveSize.buttonRadius * 0.5 : 8)
  }

  /**
   * 显示区域
   */
  @Builder
  buildDisplayArea() {
    Column() {
      // 输入显示
      Column() {
        Scroll() {
          Text(this.resultFormat(this.inputValue) || '0')
            .fontSize(this.calculateInputFontSize())
            .fontColor($r('app.color.input_text_color'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .align(Alignment.End)
      }
      .width('100%')
      .height(this.responsiveSize ? this.responsiveSize.inputHeight : 86)
      .justifyContent(FlexAlign.Center)
      .padding({
        right: this.responsiveSize ? this.responsiveSize.margin : 22
      })
      .backgroundColor($r('app.color.input_back_color'))
      .borderRadius(this.responsiveSize ? this.responsiveSize.buttonRadius * 0.5 : 8)
      
      // 计算结果显示
      if (this.calValue) {
        Column() {
          Text(this.resultFormat(this.calValue))
            .fontSize(this.calculateResultFontSize())
            .fontColor($r('app.color.text_color'))
            .opacity(0.7)
        }
        .width('100%')
        .height(this.responsiveSize ? this.responsiveSize.inputHeight * 0.5 : 43)
        .alignItems(HorizontalAlign.End)
        .padding({
          right: this.responsiveSize ? this.responsiveSize.margin : 22
        })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .margin({
      left: this.responsiveSize ? this.responsiveSize.margin : 22,
      right: this.responsiveSize ? this.responsiveSize.margin : 22,
      top: this.responsiveSize ? this.responsiveSize.margin : 20
    })
  }

  /**
   * 按键区域
   */
  @Builder
  buildKeypad() {
    Column() {
      Column({ space: this.responsiveSize ? this.responsiveSize.buttonSpacing : 8 }) {
        ForEach(keysModel.getPressKeys(), (rowItem: Array<PressKeysBean>, rowItemIndex?: number) => {
          Row({ space: this.responsiveSize ? this.responsiveSize.buttonSpacing : 8 }) {
            ForEach(rowItem, (keyItem: PressKeysBean, keyItemIndex?: number) => {
              Column() {
                if (keyItem.flag === 0) {
                  // 图标按钮
                  Image(keyItem.source !== undefined ? keyItem.source : '')
                    .width(this.responsiveSize ? this.responsiveSize.buttonFontSize * 1.2 : 24)
                    .height(this.responsiveSize ? this.responsiveSize.buttonFontSize * 1.2 : 24)
                } else {
                  // 文字按钮
                  Text(keyItem.value)
                    .fontSize(this.calculateButtonFontSize(keyItem.value))
                    .fontColor($r('app.color.text_color'))
                }
              }
              .width(this.responsiveSize ? this.responsiveSize.buttonWidth : 70)
              .height(this.responsiveSize ? this.responsiveSize.buttonHeight : 60)
              .borderWidth(1)
              .borderColor($r('app.color.border_color'))
              .borderRadius(this.responsiveSize ? this.responsiveSize.buttonRadius : 12)
              .backgroundColor($r('app.color.key_back_color'))
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                if (keyItem.flag === 0) {
                  this.inputSymbol(keyItem.value);
                } else {
                  this.inputNumber(keyItem.value);
                }
              })
            }, (keyItem: PressKeysBean) => JSON.stringify(keyItem))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }, (item: Array<Array<PressKeysBean>>) => JSON.stringify(item))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .layoutWeight(1)
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.row_back_color'))
    .padding({
      top: this.responsiveSize ? this.responsiveSize.padding : 8,
      bottom: this.responsiveSize ? this.responsiveSize.padding : 8,
      left: this.responsiveSize ? this.responsiveSize.padding : 8,
      right: this.responsiveSize ? this.responsiveSize.padding : 8
    })
  }

  /**
   * 历史记录面板（大屏右侧）
   */
  @Builder
  buildHistoryPanel() {
    Column() {
      // 标题
      Row() {
        Text($r('app.string.history_title'))
          .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize : 18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_color'))
        
        Blank()
        
        Button($r('app.string.history_clear'))
          .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.7 : 14)
          .fontColor($r('app.color.clear_text_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            HistoryUtil.clearHistory();
            this.historyList = [];
          })
      }
      .width('100%')
      .height(50)
      .margin({ bottom: 16 })
      
      // 历史记录列表
      if (this.historyList.length === 0) {
        Column() {
          Text($r('app.string.history_empty'))
            .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.8 : 16)
            .fontColor($r('app.color.text_color'))
            .opacity(0.5)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.historyList, (item: HistoryItem, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.expression)
                    .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.8 : 16)
                    .fontColor($r('app.color.text_color'))
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  
                  Text(' = ')
                    .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.8 : 16)
                    .fontColor($r('app.color.text_color'))
                  
                  Text(item.result)
                    .fontSize(this.responsiveSize ? this.responsiveSize.buttonFontSize * 0.8 : 16)
                    .fontColor($r('app.color.history_result_color'))
                    .fontWeight(FontWeight.Bold)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('100%')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              }
              .width('100%')
              .backgroundColor($r('app.color.key_back_color'))
              .borderRadius(this.responsiveSize ? this.responsiveSize.buttonRadius * 0.5 : 8)
              .margin({ top: 4, bottom: 4 })
              .onClick(() => {
                this.fillFromHistory(item.result);
              })
            }
          }, (item: HistoryItem) => item.timestamp.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .divider({
          strokeWidth: 1,
          color: $r('app.color.history_divider_color'),
          startMargin: 10,
          endMargin: 10
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 计算输入框字号（动态调整）
   */
  calculateInputFontSize(): number {
    if (!this.responsiveSize) {
      return 32;
    }
    
    const maxWidth = this.responsiveConfig.screenWidth - this.responsiveSize.margin * 2;
    const maxFontSize = this.responsiveSize.inputFontSize;
    
    // 使用 ResponsiveUtil 的自适应字号计算
    return ResponsiveUtil.calculateAdaptiveFontSize(
      this.inputValue,
      maxWidth,
      maxFontSize,
      maxFontSize * 0.4  // 最小字号为最大字号的 40%
    );
  }

  /**
   * 计算结果字号（动态调整）
   */
  calculateResultFontSize(): number {
    if (!this.responsiveSize) {
      return 20;
    }
    
    const maxWidth = this.responsiveConfig.screenWidth - this.responsiveSize.margin * 2;
    const maxFontSize = this.responsiveSize.resultFontSize;
    
    return ResponsiveUtil.calculateAdaptiveFontSize(
      this.calValue,
      maxWidth,
      maxFontSize,
      maxFontSize * 0.5
    );
  }

  /**
   * 计算按钮字号
   */
  calculateButtonFontSize(value: string): number {
    if (!this.responsiveSize) {
      return 18;
    }
    
    // 小数点使用更大的字号
    if (value === CommonConstants.DOTS) {
      return this.responsiveSize.buttonFontSize * 1.3;
    }
    
    return this.responsiveSize.buttonFontSize;
  }

  /**
   * 历史记录弹窗内容构建器
   */
  @Builder
  historySheetBuilder() {
    Column() {
      // 标题栏
      Row() {
        Text($r('app.string.history_title'))
          .fontSize($r('app.float.history_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_color'))
        Blank()
        Button($r('app.string.history_clear'))
          .fontSize(14)
          .fontColor($r('app.color.clear_text_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            // 清空历史记录
            HistoryUtil.clearHistory();
            this.historyList = [];
          })
      }
      .width('90%')
      .height(50)
      .margin({ top: 10 })

      // 历史记录列表
      if (this.historyList.length === 0) {
        // 空状态提示
        Column() {
          Text($r('app.string.history_empty'))
            .fontSize($r('app.float.history_font_size'))
            .fontColor($r('app.color.text_color'))
            .opacity(0.5)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 历史记录列表
        List() {
          ForEach(this.historyList, (item: HistoryItem, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  // 计算公式
                  Text(item.expression)
                    .fontSize($r('app.float.history_font_size'))
                    .fontColor($r('app.color.text_color'))
                    .layoutWeight(1)
                  // 等号
                  Text(' = ')
                    .fontSize($r('app.float.history_font_size'))
                    .fontColor($r('app.color.text_color'))
                  // 计算结果
                  Text(item.result)
                    .fontSize($r('app.float.history_font_size'))
                    .fontColor($r('app.color.history_result_color'))
                    .fontWeight(FontWeight.Bold)
                }
                .width('100%')
                .height($r('app.float.history_item_height'))
                .padding({ left: 15, right: 15 })
              }
              .width('100%')
              .backgroundColor($r('app.color.history_item_bg'))
              .borderRadius(10)
              .margin({ top: 5, bottom: 5 })
              .onClick(() => {
                // 点击历史记录，回填到输入框
                this.fillFromHistory(item.result);
                this.isHistoryDialogShow = false;
              })
            }
          }, (item: HistoryItem) => item.timestamp.toString())
        }
        .width('90%')
        .layoutWeight(1)
        .margin({ top: 10 })
        .divider({
          strokeWidth: 1,
          color: $r('app.color.history_divider_color'),
          startMargin: 10,
          endMargin: 10
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 从历史记录回填到输入框
   * @param result 历史记录的结果值
   */
  fillFromHistory(result: string) {
    // 清空当前输入
    this.expressions = [];
    this.calValue = '';
    // 将历史结果作为新的输入
    this.expressions.push(result);
    this.inputValue = result;
  }

  /**
   * Input Symbols.
   *
   * @param value Input Operators.
   */
  inputSymbol(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return;
    }
    let len = this.expressions.length;
    switch (value) {
      case Symbol.CLEAN:
        this.expressions = [];
        this.calValue = '';
        break;
      case Symbol.DEL:
        this.inputDelete(len);
        break;
      case Symbol.EQU:
        if (len === 0) {
          return;
        }
        // 保存计算前的公式用于历史记录
        let historyExpression = this.inputValue;
        this.getResult().then((result: boolean) => {
          if (!result) {
            return;
          }
          // 保存历史记录：计算公式 + 计算结果
          HistoryUtil.addHistory(historyExpression, this.calValue);
          this.inputValue = this.calValue;
          this.calValue = '';
          this.expressions = [];
          this.expressions.push(this.inputValue);
          // 保存状态到AppStorage（用于迁移）
          this.saveCalculatorState();
        })
        break;
      default:
        this.inputOperators(len, value);
        break;
    }
    this.formatInputValue();
    // 保存状态到AppStorage（用于迁移）
    this.saveCalculatorState();
  }

  /**
   * 保存计算器状态到AppStorage
   * 用于分布式迁移时读取当前状态
   */
  private saveCalculatorState(): void {
    AppStorage.setOrCreate('calculator_inputValue', this.inputValue);
    AppStorage.setOrCreate('calculator_calValue', this.calValue);
    AppStorage.setOrCreate('calculator_expressions', [...this.expressions]);
  }

  /**
   * Enter numbers.
   *
   * @param value Enter numbers.
   */
  inputNumber(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return;
    }
    let len = this.expressions.length;
    let last = len > 0 ? this.expressions[len - 1] : '';
    let secondLast = len > 1 ? this.expressions[len - CommonConstants.TWO] : undefined;
    if (!this.validateEnter(last, value)) {
      return;
    }
    if (!last) {
      this.expressions.push(value);
    } else if (!secondLast) {
      this.expressions[len - 1] += value;
    }
    if (secondLast && CalculateUtil.isSymbol(secondLast)) {
      this.expressions[len -1] += value;
    }
    if (secondLast && !CalculateUtil.isSymbol(secondLast)) {
      this.expressions.push(value);
    }
    this.formatInputValue();
    if (value !== CommonConstants.DOTS) {
      this.getResult();
    }
    // 保存状态到AppStorage（用于迁移）
    this.saveCalculatorState();
  }

  /**
   * Verify that you can enter.
   *
   * @param last Value of the last element.
   * @param value Current input value.
   * return Indicates whether to allow input.
   */
  validateEnter(last: string, value: string) {
    if (!last && value === CommonConstants.PERCENT_SIGN) {
      return false;
    }
    if ((last === CommonConstants.MIN) && (value === CommonConstants.PERCENT_SIGN)) {
      return false;
    }
    if (last.endsWith(CommonConstants.PERCENT_SIGN)) {
      return false;
    }
    if ((last.indexOf(CommonConstants.DOTS) !== -1) && (value === CommonConstants.DOTS)) {
      return false;
    }
    if ((last === '0') && (value !== CommonConstants.DOTS) &&
      (value !== CommonConstants.PERCENT_SIGN)) {
      return false;
    }
    return true;
  }

  /**
   * Delete Key Trigger.
   *
   * @param len Expression Length.
   */
  inputDelete(len: number) {
    if (len === 0) {
      return;
    }
    let last = this.expressions[len - 1];
    let lastLen = last.length;
    if (lastLen === 1) {
      this.expressions.pop();
      len = this.expressions.length;
    } else {
      this.expressions[len - 1] = last.slice(0, last.length - 1);
    }
    if (len === 0) {
      this.inputValue = '';
      this.calValue = '';
      return;
    }
    if (!CalculateUtil.isSymbol(this.expressions[len - 1])) {
      this.getResult();
    }
  }

  /**
   * Triggered when input is added, subtracted, multiplied, and divided.
   *
   * @param len Expression Length.
   * @param value Current Input Value.
   */
  inputOperators(len: number, value: string) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    let secondLast = len > 1 ? this.expressions[len - CommonConstants.TWO] : undefined;
    if (!last && (value === Symbol.MIN)) {
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if (!last) {
      return;
    }
    if (!CalculateUtil.isSymbol(last)) {
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if ((value === Symbol.MIN) &&
      (last === CommonConstants.MIN || last === CommonConstants.ADD)) {
      this.expressions.pop();
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if (!secondLast) {
      return;
    }
    if (value !== Symbol.MIN) {
      this.expressions.pop();
    }
    if (CalculateUtil.isSymbol(secondLast)) {
      this.expressions.pop();
    }
    this.expressions.push(this.getSymbol(value));
  }

  /**
   * Get Operator.
   *
   * @param value.
   * @return Operators.
   */
  getSymbol(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return '';
    }
    let symbol = '';
    switch (value) {
      case Symbol.ADD:
        symbol = CommonConstants.ADD;
        break;
      case Symbol.MIN:
        symbol = CommonConstants.MIN;
        break;
      case Symbol.MUL:
        symbol = CommonConstants.MUL;
        break;
      case Symbol.DIV:
        symbol = CommonConstants.DIV;
        break;
      default:
        break;
    }
    return symbol;
  }

  /**
   * Make a deep copy of an expression.
   *
   * @return deep copy expression.
   */
  deepCopy(): Array<string> {
    let copyExpressions: Array<string> = Array.from(this.expressions);
    return copyExpressions;
  }

  /**
   * Obtaining Results.
   *
   * @return Whether the result is incorrect.
   */
  async getResult() {
    let calResult = CalculateUtil.parseExpression(this.deepCopy());
    if (calResult === 'NaN') {
      this.calValue = this.resourceToString($r('app.string.error'));
      return false;
    }
    this.calValue = calResult;
    return true;
  }

  /**
   * Number Formatting.
   *
   * @param value Formatting parameters.
   * @return Thousand percentile data.
   */
  resultFormat(value: string) {
    let reg = (value.indexOf('.') > -1) ? new RegExp("/(\d)(?=(\d{3})+\.)/g") : new RegExp("/(\d)(?=(?:\d{3})+$)/g");
    return value.replace(reg, '$1,');
  }

  /**
   * Convert a resource file to a string.
   *
   * @param resource Resource file.
   * @return Character string converted from the resource file.
   */
  resourceToString(resource: Resource): string {
    if (CheckEmptyUtil.isEmpty(resource)) {
      return '';
    }
    let result = '';
    try {
      const uiContext: UIContext | undefined = AppStorage.get('uiContext');
      let context = uiContext!.getHostContext()!;
      result = context.resourceManager.getStringSync(resource.id);
    } catch (error) {
      Logger.error('[CalculateModel] getResourceString fail: ' + JSON.stringify(error))
    }
    return result;
  }

  /**
   * Thousands in the formatting result.
   */
  formatInputValue() {
    let deepExpressions: Array<string> = [];
    this.deepCopy().forEach((item: string, index: number) => {
      deepExpressions[index] = this.resultFormat(item);
    });
    this.inputValue = deepExpressions.join('');
  }

  /**
   * 生成随机数并填充到计算器显示屏
   */
  generateRandomNumber(): void {
    // 验证输入是否为空
    if (!this.randomMin || !this.randomMax) {
      this.randomError = '请输入完整的区间范围';
      return;
    }

    // 解析上下限
    const min = parseInt(this.randomMin);
    const max = parseInt(this.randomMax);

    // 验证是否为有效数字
    if (isNaN(min) || isNaN(max)) {
      this.randomError = '请输入有效的整数';
      return;
    }

    // 验证区间是否合法
    if (min > max) {
      this.randomError = '下限不能大于上限';
      return;
    }

    // 生成随机整数
    const randomNum = Math.floor(Math.random() * (max - min + 1)) + min;
    const randomStr = randomNum.toString();

    // 清空当前输入和计算结果
    this.expressions = [];
    this.calValue = '';
    
    // 将随机数填充到显示屏
    this.expressions.push(randomStr);
    this.inputValue = randomStr;
    
    // 清空错误提示
    this.randomError = '';
    
    // 显示提示
    promptAction.showToast({
      message: `已生成随机数: ${randomStr}`,
      duration: 1500
    });
  }
}