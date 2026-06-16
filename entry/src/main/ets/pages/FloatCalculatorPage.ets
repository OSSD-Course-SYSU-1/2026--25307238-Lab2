/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { window } from '@kit.ArkUI';
import CalculateUtil from '../common/util/CalculateUtil';
import FloatWindowUtil from '../common/util/FloatWindowUtil';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'FloatCalculatorPage';
const DOMAIN = 0x0000;

/**
 * 悬浮窗计算器页面
 * 提供精简的计算器功能，支持拖动
 */
@Entry
@Component
struct FloatCalculatorPage {
  @State inputValue: string = '';
  @State calValue: string = '';
  private expressions: Array<string> = [];
  private floatWindow: window.Window | null = null;

  // 拖动相关
  private startX: number = 0;
  private startY: number = 0;
  private windowStartX: number = 0;
  private windowStartY: number = 0;

  aboutToAppear(): void {
    // 获取悬浮窗实例
    this.floatWindow = FloatWindowUtil.getFloatWindow();
    hilog.info(DOMAIN, TAG, 'FloatCalculatorPage aboutToAppear, window: %{public}s', 
      this.floatWindow ? 'not null' : 'null');
  }

  build() {
    Column() {
      // 顶部拖动区域和关闭按钮
      this.buildTitleBar();

      // 显示区域
      this.buildDisplayArea();

      // 按键区域
      this.buildKeypad();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  /**
   * 构建标题栏（可拖动）
   */
  @Builder
  buildTitleBar() {
    Row() {
      // 拖动手势指示
      Row()
        .width(40)
        .height(4)
        .backgroundColor('#CCCCCC')
        .borderRadius(2)

      Blank()

      // 关闭按钮
      Button({ type: ButtonType.Circle }) {
        Text('×')
          .fontSize(18)
          .fontColor('#666666')
          .fontWeight(FontWeight.Bold)
      }
      .width(28)
      .height(28)
      .backgroundColor('#F0F0F0')
      .onClick(() => {
        this.closeFloatWindow();
      })
    }
    .width('100%')
    .height(36)
    .padding({ left: 12, right: 8 })
    .justifyContent(FlexAlign.Center)
    .gesture(
      PanGesture({ direction: PanDirection.All })
        .onActionStart((event: GestureEvent) => {
          this.startX = event.offsetX;
          this.startY = event.offsetY;
          if (this.floatWindow) {
            const props = this.floatWindow.getWindowProperties();
            this.windowStartX = props.windowRect.left;
            this.windowStartY = props.windowRect.top;
          }
        })
        .onActionUpdate((event: GestureEvent) => {
          if (this.floatWindow) {
            const deltaX = event.offsetX - this.startX;
            const deltaY = event.offsetY - this.startY;
            const newX = this.windowStartX + deltaX;
            const newY = this.windowStartY + deltaY;
            this.floatWindow.moveWindowTo(newX, newY);
          }
        })
    )
  }

  /**
   * 构建显示区域
   */
  @Builder
  buildDisplayArea() {
    Column() {
      // 输入表达式
      Text(this.inputValue || '0')
        .fontSize(this.inputValue.length > 8 ? 20 : 26)
        .fontColor('#182431')
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .textAlign(TextAlign.End)
        .padding({ right: 12 })

      // 计算结果
      if (this.calValue) {
        Text(this.calValue)
          .fontSize(18)
          .fontColor('#007DFF')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.End)
          .padding({ right: 12, top: 4 })
      }
    }
    .width('100%')
    .height(70)
    .justifyContent(FlexAlign.End)
    .padding({ bottom: 8 })
  }

  /**
   * 构建按键区域
   */
  @Builder
  buildKeypad() {
    Column({ space: 6 }) {
      // 第一行：C, ÷, ×, 退格
      Row({ space: 6 }) {
        this.buildKey('C', '#FF6B6B')
        this.buildKey('÷', '#E8F4FF')
        this.buildKey('×', '#E8F4FF')
        this.buildKey('⌫', '#E8F4FF')
      }

      // 第二行：7, 8, 9, -
      Row({ space: 6 }) {
        this.buildKey('7')
        this.buildKey('8')
        this.buildKey('9')
        this.buildKey('-', '#E8F4FF')
      }

      // 第三行：4, 5, 6, +
      Row({ space: 6 }) {
        this.buildKey('4')
        this.buildKey('5')
        this.buildKey('6')
        this.buildKey('+', '#E8F4FF')
      }

      // 第四行：1, 2, 3, =
      Row({ space: 6 }) {
        this.buildKey('1')
        this.buildKey('2')
        this.buildKey('3')
        this.buildKey('=', '#007DFF', true)
      }

      // 第五行：%, 0, .
      Row({ space: 6 }) {
        this.buildKey('%')
        this.buildKey('0')
        this.buildKey('.')
        Blank().layoutWeight(1)
      }
    }
    .width('100%')
    .padding({ left: 8, right: 8, bottom: 8 })
    .layoutWeight(1)
  }

  /**
   * 构建单个按键
   */
  @Builder
  buildKey(label: string, bgColor: string = '#FFFFFF', isEquals: boolean = false) {
    Column() {
      Text(label)
        .fontSize(18)
        .fontColor(isEquals ? '#FFFFFF' : '#182431')
        .fontWeight(isEquals ? FontWeight.Bold : FontWeight.Normal)
    }
    .width(54)
    .height(42)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(bgColor)
    .borderRadius(8)
    .onClick(() => {
      this.onKeyPress(label);
    })
  }

  /**
   * 按键处理
   */
  onKeyPress(key: string): void {
    switch (key) {
      case 'C':
        this.clearAll();
        break;
      case '⌫':
        this.deleteLast();
        break;
      case '=':
        this.calculate();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
      case '%':
        this.inputOperator(key);
        break;
      default:
        this.inputNumber(key);
        break;
    }
  }

  /**
   * 输入数字
   */
  inputNumber(num: string): void {
    const len = this.expressions.length;
    const last = len > 0 ? this.expressions[len - 1] : '';
    
    if (num === '.') {
      if (len === 0) {
        this.expressions.push('0.');
      } else if (!CalculateUtil.isSymbol(last) && !last.includes('.')) {
        this.expressions[len - 1] = last + '.';
      }
    } else {
      if (len === 0 || CalculateUtil.isSymbol(last)) {
        this.expressions.push(num);
      } else {
        if (last === '0') {
          this.expressions[len - 1] = num;
        } else {
          this.expressions[len - 1] = last + num;
        }
      }
    }
    
    this.formatInputValue();
    this.calculateResult();
  }

  /**
   * 输入运算符
   */
  inputOperator(op: string): void {
    const len = this.expressions.length;
    if (len === 0 && op === '-') {
      this.expressions.push(op);
    } else if (len > 0 && !CalculateUtil.isSymbol(this.expressions[len - 1])) {
      this.expressions.push(op);
    } else if (len > 0 && CalculateUtil.isSymbol(this.expressions[len - 1])) {
      this.expressions[len - 1] = op;
    }
    this.formatInputValue();
  }

  /**
   * 清空所有
   */
  clearAll(): void {
    this.expressions = [];
    this.inputValue = '';
    this.calValue = '';
  }

  /**
   * 删除最后一个字符
   */
  deleteLast(): void {
    if (this.expressions.length === 0) {
      return;
    }
    const last = this.expressions[this.expressions.length - 1];
    if (last.length > 1) {
      this.expressions[this.expressions.length - 1] = last.slice(0, last.length - 1);
    } else {
      this.expressions.pop();
    }
    if (this.expressions.length === 0) {
      this.inputValue = '';
      this.calValue = '';
      return;
    }
    this.formatInputValue();
    this.calculateResult();
  }

  /**
   * 执行计算
   */
  calculate(): void {
    if (this.expressions.length === 0) {
      return;
    }
    this.calculateResult();
    if (this.calValue && this.calValue !== 'error' && this.calValue !== 'NaN') {
      this.inputValue = this.calValue;
      this.calValue = '';
      this.expressions = [];
      this.expressions.push(this.inputValue);
    }
  }

  /**
   * 计算结果
   */
  calculateResult(): void {
    const result = CalculateUtil.parseExpression([...this.expressions]);
    if (result === 'NaN') {
      this.calValue = 'error';
    } else {
      this.calValue = result;
    }
  }

  /**
   * 格式化输入值
   */
  formatInputValue(): void {
    this.inputValue = this.expressions.join('');
  }

  /**
   * 关闭悬浮窗
   */
  closeFloatWindow(): void {
    hilog.info(DOMAIN, TAG, 'closeFloatWindow called');
    FloatWindowUtil.destroyFloatWindow();
  }
}
