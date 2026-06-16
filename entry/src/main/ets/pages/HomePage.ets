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
import FloatWindowUtil from '../common/util/FloatWindowUtil';
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
  /** 悬浮计算器Sheet显示状态 */
  @State isFloatSheetShow: boolean = false;
  /** 随机数下限 */
  @State randomMin: string = '';
  /** 随机数上限 */
  @State randomMax: string = '';
  /** 随机数错误提示 */
  @State randomError: string = '';

  /** 主题管理键名 */
  private static readonly THEME_KEY: string = 'currentThemeMode';

  /** 页面即将显示时初始化主题 */
  aboutToAppear(): void {
    // 初始化主题管理
    ThemeUtil.init();
  }

  build() {
    Column() {
      // 顶部按钮区域：主题切换 + 悬浮窗 + 历史记录
      Row() {
        // 主题切换按钮（左上角）
        Button({ type: ButtonType.Circle }) {
          // 根据当前主题显示不同图标
          if (this.currentThemeMode === ThemeMode.LIGHT) {
            // 浅色模式显示月亮图标（点击切换到深色）
            Text('🌙')
              .fontSize(20)
          } else {
            // 深色模式显示太阳图标（点击切换到浅色）
            Text('☀️')
              .fontSize(20)
          }
        }
        .width($r('app.float.history_button_size'))
        .height($r('app.float.history_button_size'))
        .backgroundColor($r('app.color.theme_button_color'))
        .onClick(() => {
          // 切换主题
          ThemeUtil.toggleTheme();
        })

        Blank()

        // 悬浮窗按钮（右上角）
        Button({ type: ButtonType.Circle }) {
          Text('📱')
            .fontSize(16)
        }
        .width($r('app.float.history_button_size'))
        .height($r('app.float.history_button_size'))
        .backgroundColor($r('app.color.history_button_color'))
        .margin({ right: 8 })
        .onClick(() => {
          // 显示悬浮计算器Sheet
          this.isFloatSheetShow = true;
        })

        // 历史记录按钮（右上角）
        Button({ type: ButtonType.Circle }) {
          Text($r('app.string.history_button'))
            .fontSize(12)
            .fontColor($r('app.color.text_color'))
        }
        .width($r('app.float.history_button_size'))
        .height($r('app.float.history_button_size'))
        .backgroundColor($r('app.color.history_button_color'))
        .onClick(() => {
          // 点击历史记录按钮，刷新列表并显示弹窗
          this.historyList = HistoryUtil.getHistoryList();
          this.isHistoryDialogShow = true;
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .margin({
        left: $r('app.float.input_margin_right'),
        right: $r('app.float.input_margin_right'),
        top: '20vp'
      })

      // 随机数模块
      Column() {
        Row({ space: 8 }) {
          Text('随机数区间：')
            .fontSize(14)
            .fontColor($r('app.color.text_color'))
          
          TextInput({ placeholder: '下限', text: this.randomMin })
            .width(80)
            .height(36)
            .fontSize(14)
            .type(InputType.Number)
            .textAlign(TextAlign.Center)
            .onChange((value: string) => {
              this.randomMin = value;
              this.randomError = '';
            })
          
          Text('~')
            .fontSize(16)
            .fontColor($r('app.color.text_color'))
            .fontWeight(FontWeight.Bold)
          
          TextInput({ placeholder: '上限', text: this.randomMax })
            .width(80)
            .height(36)
            .fontSize(14)
            .type(InputType.Number)
            .textAlign(TextAlign.Center)
            .onChange((value: string) => {
              this.randomMax = value;
              this.randomError = '';
            })
          
          Button('生成随机数')
            .width(90)
            .height(36)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#007DFF')
            .fontColor(Color.White)
            .borderRadius(6)
            .onClick(() => {
              this.generateRandomNumber();
            })
        }
        .width('100%')
        .height(36)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        
        if (this.randomError) {
          Row() {
            Text('⚠ ' + this.randomError)
              .fontSize(12)
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
        left: $r('app.float.input_margin_right'),
        right: $r('app.float.input_margin_right'),
        top: '12vp'
      })
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor($r('app.color.history_item_bg'))
      .borderRadius(8)

      Column() {
        TextInput({ text: this.resultFormat(this.inputValue) })
          .height(CommonConstants.FULL_PERCENT)
          .fontSize(
            (this.inputValue.length > CommonConstants.INPUT_LENGTH_MAX) ?
              $r('app.float.font_size_text') : $r('app.float.font_size_input')
          )
          .enabled(false)
          .fontColor($r('app.color.input_text_color'))
          .textAlign(TextAlign.End)
          .backgroundColor($r('app.color.input_back_color'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.input_height'))
      .alignItems(HorizontalAlign.End)
      .margin({
        right: $r('app.float.input_margin_right'),
        top: $r('app.float.input_margin_top')
      })

      Column() {
        Text(this.resultFormat(this.calValue))
          .fontSize($r('app.float.font_size_text'))
          .fontColor($r('app.color.text_color'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.text_height'))
      .alignItems(HorizontalAlign.End)
      .margin({
        right: $r('app.float.text_margin_right'),
        bottom: $r('app.float.text_margin_bottom')
      })

      Column() {
        Column({ space: 8 }) {
          ForEach(keysModel.getPressKeys(), (rowItem: Array<PressKeysBean>, rowItemIndex?: number) => {
            Row({ space: 8 }) {
              ForEach(rowItem, (keyItem: PressKeysBean, keyItemIndex?: number) => {
                Column() {
                  if (keyItem.flag === 0) {
                    Image(keyItem.source !== undefined ? keyItem.source : '')
                      .width(keyItem.width)
                      .height(keyItem.height)
                  } else {
                    Text(keyItem.value)
                      .fontSize(
                        (keyItem.value === CommonConstants.DOTS) ?
                          $r('app.float.font_size_dot') : $r('app.float.font_size_text')
                      )
                      .fontColor($r('app.color.text_color'))
                  }
                }
                .width($r('app.float.key_width'))
                .height($r('app.float.key_height'))
                .borderWidth(1)
                .borderColor($r('app.color.border_color'))
                .borderRadius($r('app.float.border_radius'))
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
      .padding({ top: 8, bottom: 8 })
    }
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.column_back_color'))
    .bindSheet($$this.isHistoryDialogShow, this.historySheetBuilder(), {
      height: $r('app.float.history_dialog_height'),
      backgroundColor: $r('app.color.history_dialog_bg'),
      dragBar: true,
      showClose: true
    })
    .bindSheet($$this.isFloatSheetShow, this.floatCalculatorSheetBuilder(), {
      height: 420,
      backgroundColor: $r('app.color.column_back_color'),
      dragBar: true,
      showClose: false
    })
  }

  /**
   * 悬浮计算器Sheet内容构建器
   */
  @Builder
  floatCalculatorSheetBuilder() {
    Column() {
      // 标题栏
      Row() {
        Text('快捷计算器')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_color'))
        Blank()
        Button({ type: ButtonType.Circle }) {
          Text('×')
            .fontSize(18)
            .fontColor($r('app.color.text_color'))
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.isFloatSheetShow = false;
        })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 8 })

      // 显示区域
      Column() {
        Text(this.inputValue || '0')
          .fontSize(this.inputValue.length > 8 ? 24 : 32)
          .fontColor($r('app.color.input_text_color'))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.End)
          .padding({ right: 16 })

        if (this.calValue) {
          Text(this.calValue)
            .fontSize(20)
            .fontColor('#007DFF')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .textAlign(TextAlign.End)
            .padding({ right: 16, top: 4 })
        }
      }
      .width('100%')
      .height(80)
      .justifyContent(FlexAlign.End)
      .padding({ bottom: 8 })

      // 按键区域
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          this.buildFloatKey('C', '#FF6B6B')
          this.buildFloatKey('÷', '#E8F4FF')
          this.buildFloatKey('×', '#E8F4FF')
          this.buildFloatKey('⌫', '#E8F4FF')
        }
        Row({ space: 8 }) {
          this.buildFloatKey('7')
          this.buildFloatKey('8')
          this.buildFloatKey('9')
          this.buildFloatKey('-', '#E8F4FF')
        }
        Row({ space: 8 }) {
          this.buildFloatKey('4')
          this.buildFloatKey('5')
          this.buildFloatKey('6')
          this.buildFloatKey('+', '#E8F4FF')
        }
        Row({ space: 8 }) {
          this.buildFloatKey('1')
          this.buildFloatKey('2')
          this.buildFloatKey('3')
          this.buildFloatKey('=', '#007DFF', true)
        }
        Row({ space: 8 }) {
          this.buildFloatKey('%')
          this.buildFloatKey('0')
          this.buildFloatKey('.')
          Blank().layoutWeight(1)
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12, bottom: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建悬浮计算器按键
   */
  @Builder
  buildFloatKey(label: string, bgColor: string = '#FFFFFF', isEquals: boolean = false) {
    Column() {
      Text(label)
        .fontSize(20)
        .fontColor(isEquals ? '#FFFFFF' : $r('app.color.text_color'))
        .fontWeight(isEquals ? FontWeight.Bold : FontWeight.Normal)
    }
    .width(72)
    .height(48)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(bgColor)
    .borderRadius(12)
    .onClick(() => {
      this.onFloatKeyPress(label);
    })
  }

  /**
   * 悬浮计算器按键处理
   */
  onFloatKeyPress(key: string): void {
    switch (key) {
      case 'C':
        this.inputSymbol(Symbol.CLEAN);
        break;
      case '⌫':
        this.inputSymbol(Symbol.DEL);
        break;
      case '=':
        this.inputSymbol(Symbol.EQU);
        break;
      case '+':
        this.inputSymbol(Symbol.ADD);
        break;
      case '-':
        this.inputSymbol(Symbol.MIN);
        break;
      case '×':
        this.inputSymbol(Symbol.MUL);
        break;
      case '÷':
        this.inputSymbol(Symbol.DIV);
        break;
      default:
        this.inputNumber(key);
        break;
    }
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
   * 开启悬浮窗计算器
   */
  async openFloatWindow() {
    promptAction.showToast({ message: '正在开启悬浮窗...', duration: 1000 });
    
    const context = AppStorage.get<common.UIAbilityContext>('uiAbilityContext');
    if (!context) {
      promptAction.showToast({ message: '获取上下文失败', duration: 2000 });
      Logger.error('HomePage', 'UIAbilityContext is null');
      return;
    }
    
    const success = await FloatWindowUtil.showFloatWindow(context);
    if (success) {
      promptAction.showToast({ message: '悬浮窗已开启', duration: 1500 });
      Logger.info('HomePage', 'Float window opened successfully');
    } else {
      promptAction.showToast({ message: '悬浮窗开启失败', duration: 2000 });
      Logger.error('HomePage', 'Failed to open float window');
    }
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
        })
        break;
      default:
        this.inputOperators(len, value);
        break;
    }
    this.formatInputValue();
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