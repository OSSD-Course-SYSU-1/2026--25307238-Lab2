if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface FloatCalculatorPage_Params {
    inputValue?: string;
    calValue?: string;
    expressions?: Array<string>;
    floatWindow?: window.Window | null;
    startX?: number;
    startY?: number;
    windowStartX?: number;
    windowStartY?: number;
}
import type window from "@ohos:window";
import CalculateUtil from "@bundle:com.example.simplecalculator/entry/ets/common/util/CalculateUtil";
import FloatWindowUtil from "@bundle:com.example.simplecalculator/entry/ets/common/util/FloatWindowUtil";
import hilog from "@ohos:hilog";
const TAG = 'FloatCalculatorPage';
const DOMAIN = 0x0000;
class FloatCalculatorPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__inputValue = new ObservedPropertySimplePU('', this, "inputValue");
        this.__calValue = new ObservedPropertySimplePU('', this, "calValue");
        this.expressions = [];
        this.floatWindow = null;
        this.startX = 0;
        this.startY = 0;
        this.windowStartX = 0;
        this.windowStartY = 0;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: FloatCalculatorPage_Params) {
        if (params.inputValue !== undefined) {
            this.inputValue = params.inputValue;
        }
        if (params.calValue !== undefined) {
            this.calValue = params.calValue;
        }
        if (params.expressions !== undefined) {
            this.expressions = params.expressions;
        }
        if (params.floatWindow !== undefined) {
            this.floatWindow = params.floatWindow;
        }
        if (params.startX !== undefined) {
            this.startX = params.startX;
        }
        if (params.startY !== undefined) {
            this.startY = params.startY;
        }
        if (params.windowStartX !== undefined) {
            this.windowStartX = params.windowStartX;
        }
        if (params.windowStartY !== undefined) {
            this.windowStartY = params.windowStartY;
        }
    }
    updateStateVars(params: FloatCalculatorPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__inputValue.purgeDependencyOnElmtId(rmElmtId);
        this.__calValue.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__inputValue.aboutToBeDeleted();
        this.__calValue.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __inputValue: ObservedPropertySimplePU<string>;
    get inputValue() {
        return this.__inputValue.get();
    }
    set inputValue(newValue: string) {
        this.__inputValue.set(newValue);
    }
    private __calValue: ObservedPropertySimplePU<string>;
    get calValue() {
        return this.__calValue.get();
    }
    set calValue(newValue: string) {
        this.__calValue.set(newValue);
    }
    private expressions: Array<string>;
    private floatWindow: window.Window | null;
    // 拖动相关
    private startX: number;
    private startY: number;
    private windowStartX: number;
    private windowStartY: number;
    aboutToAppear(): void {
        // 获取悬浮窗实例
        this.floatWindow = FloatWindowUtil.getFloatWindow();
        hilog.info(DOMAIN, TAG, 'FloatCalculatorPage aboutToAppear, window: %{public}s', this.floatWindow ? 'not null' : 'null');
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#FFFFFF');
            Column.borderRadius(16);
        }, Column);
        // 顶部拖动区域和关闭按钮
        this.buildTitleBar.bind(this)();
        // 显示区域
        this.buildDisplayArea.bind(this)();
        // 按键区域
        this.buildKeypad.bind(this)();
        Column.pop();
    }
    /**
     * 构建标题栏（可拖动）
     */
    buildTitleBar(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(36);
            Row.padding({ left: 12, right: 8 });
            Row.justifyContent(FlexAlign.Center);
            Gesture.create(GesturePriority.Low);
            PanGesture.create({ direction: PanDirection.All });
            PanGesture.onActionStart((event: GestureEvent) => {
                this.startX = event.offsetX;
                this.startY = event.offsetY;
                if (this.floatWindow) {
                    const props = this.floatWindow.getWindowProperties();
                    this.windowStartX = props.windowRect.left;
                    this.windowStartY = props.windowRect.top;
                }
            });
            PanGesture.onActionUpdate((event: GestureEvent) => {
                if (this.floatWindow) {
                    const deltaX = event.offsetX - this.startX;
                    const deltaY = event.offsetY - this.startY;
                    const newX = this.windowStartX + deltaX;
                    const newY = this.windowStartY + deltaY;
                    this.floatWindow.moveWindowTo(newX, newY);
                }
            });
            PanGesture.pop();
            Gesture.pop();
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 拖动手势指示
            Row.create();
            // 拖动手势指示
            Row.width(40);
            // 拖动手势指示
            Row.height(4);
            // 拖动手势指示
            Row.backgroundColor('#CCCCCC');
            // 拖动手势指示
            Row.borderRadius(2);
        }, Row);
        // 拖动手势指示
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 关闭按钮
            Button.createWithChild({ type: ButtonType.Circle });
            // 关闭按钮
            Button.width(28);
            // 关闭按钮
            Button.height(28);
            // 关闭按钮
            Button.backgroundColor('#F0F0F0');
            // 关闭按钮
            Button.onClick(() => {
                this.closeFloatWindow();
            });
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('×');
            Text.fontSize(18);
            Text.fontColor('#666666');
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        // 关闭按钮
        Button.pop();
        Row.pop();
    }
    /**
     * 构建显示区域
     */
    buildDisplayArea(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height(70);
            Column.justifyContent(FlexAlign.End);
            Column.padding({ bottom: 8 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 输入表达式
            Text.create(this.inputValue || '0');
            // 输入表达式
            Text.fontSize(this.inputValue.length > 8 ? 20 : 26);
            // 输入表达式
            Text.fontColor('#182431');
            // 输入表达式
            Text.fontWeight(FontWeight.Medium);
            // 输入表达式
            Text.maxLines(1);
            // 输入表达式
            Text.textOverflow({ overflow: TextOverflow.Ellipsis });
            // 输入表达式
            Text.width('100%');
            // 输入表达式
            Text.textAlign(TextAlign.End);
            // 输入表达式
            Text.padding({ right: 12 });
        }, Text);
        // 输入表达式
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 计算结果
            if (this.calValue) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.calValue);
                        Text.fontSize(18);
                        Text.fontColor('#007DFF');
                        Text.maxLines(1);
                        Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                        Text.width('100%');
                        Text.textAlign(TextAlign.End);
                        Text.padding({ right: 12, top: 4 });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    /**
     * 构建按键区域
     */
    buildKeypad(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 6 });
            Column.width('100%');
            Column.padding({ left: 8, right: 8, bottom: 8 });
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 第一行：C, ÷, ×, 退格
            Row.create({ space: 6 });
        }, Row);
        this.buildKey.bind(this)('C', '#FF6B6B');
        this.buildKey.bind(this)('÷', '#E8F4FF');
        this.buildKey.bind(this)('×', '#E8F4FF');
        this.buildKey.bind(this)('⌫', '#E8F4FF');
        // 第一行：C, ÷, ×, 退格
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 第二行：7, 8, 9, -
            Row.create({ space: 6 });
        }, Row);
        this.buildKey.bind(this)('7');
        this.buildKey.bind(this)('8');
        this.buildKey.bind(this)('9');
        this.buildKey.bind(this)('-', '#E8F4FF');
        // 第二行：7, 8, 9, -
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 第三行：4, 5, 6, +
            Row.create({ space: 6 });
        }, Row);
        this.buildKey.bind(this)('4');
        this.buildKey.bind(this)('5');
        this.buildKey.bind(this)('6');
        this.buildKey.bind(this)('+', '#E8F4FF');
        // 第三行：4, 5, 6, +
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 第四行：1, 2, 3, =
            Row.create({ space: 6 });
        }, Row);
        this.buildKey.bind(this)('1');
        this.buildKey.bind(this)('2');
        this.buildKey.bind(this)('3');
        this.buildKey.bind(this)('=', '#007DFF', true);
        // 第四行：1, 2, 3, =
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 第五行：%, 0, .
            Row.create({ space: 6 });
        }, Row);
        this.buildKey.bind(this)('%');
        this.buildKey.bind(this)('0');
        this.buildKey.bind(this)('.');
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.layoutWeight(1);
        }, Blank);
        Blank.pop();
        // 第五行：%, 0, .
        Row.pop();
        Column.pop();
    }
    /**
     * 构建单个按键
     */
    buildKey(label: string, bgColor: string = '#FFFFFF', isEquals: boolean = false, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(54);
            Column.height(42);
            Column.justifyContent(FlexAlign.Center);
            Column.backgroundColor(bgColor);
            Column.borderRadius(8);
            Column.onClick(() => {
                this.onKeyPress(label);
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(label);
            Text.fontSize(18);
            Text.fontColor(isEquals ? '#FFFFFF' : '#182431');
            Text.fontWeight(isEquals ? FontWeight.Bold : FontWeight.Normal);
        }, Text);
        Text.pop();
        Column.pop();
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
            }
            else if (!CalculateUtil.isSymbol(last) && !last.includes('.')) {
                this.expressions[len - 1] = last + '.';
            }
        }
        else {
            if (len === 0 || CalculateUtil.isSymbol(last)) {
                this.expressions.push(num);
            }
            else {
                if (last === '0') {
                    this.expressions[len - 1] = num;
                }
                else {
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
        }
        else if (len > 0 && !CalculateUtil.isSymbol(this.expressions[len - 1])) {
            this.expressions.push(op);
        }
        else if (len > 0 && CalculateUtil.isSymbol(this.expressions[len - 1])) {
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
        }
        else {
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
        }
        else {
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
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "FloatCalculatorPage";
    }
}
registerNamedRoute(() => new FloatCalculatorPage(undefined, {}), "", { bundleName: "com.example.simplecalculator", moduleName: "entry", pagePath: "pages/FloatCalculatorPage", pageFullPath: "entry/src/main/ets/pages/FloatCalculatorPage", integratedHsp: "false", moduleType: "followWithHap" });
