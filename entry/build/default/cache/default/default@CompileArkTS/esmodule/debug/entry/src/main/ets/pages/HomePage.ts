if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface HomePage_Params {
    inputValue?: string;
    calValue?: string;
    expressions?: Array<string>;
    isHistoryDialogShow?: boolean;
    historyList?: Array<HistoryItem>;
    currentThemeMode?: number;
}
import Logger from "@bundle:com.example.simplecalculator/entry/ets/common/util/Logger";
import CalculateUtil from "@bundle:com.example.simplecalculator/entry/ets/common/util/CalculateUtil";
import CheckEmptyUtil from "@bundle:com.example.simplecalculator/entry/ets/common/util/CheckEmptyUtil";
import HistoryUtil from "@bundle:com.example.simplecalculator/entry/ets/common/util/HistoryUtil";
import ThemeUtil, { ThemeMode } from "@bundle:com.example.simplecalculator/entry/ets/common/util/ThemeUtil";
import keysModel from "@bundle:com.example.simplecalculator/entry/ets/viewmodel/PresskeysViewModel";
import type { PressKeysBean } from '../viewmodel/PressKeysItem';
import type { HistoryItem } from '../viewmodel/HistoryItem';
import { CommonConstants, Symbol } from "@bundle:com.example.simplecalculator/entry/ets/common/constants/CommonConstants";
class HomePage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__inputValue = new ObservedPropertySimplePU('', this, "inputValue");
        this.__calValue = new ObservedPropertySimplePU('', this, "calValue");
        this.expressions = [];
        this.__isHistoryDialogShow = new ObservedPropertySimplePU(false, this, "isHistoryDialogShow");
        this.__historyList = new ObservedPropertyObjectPU([], this, "historyList");
        this.__currentThemeMode = this.createStorageLink('currentThemeMode', ThemeMode.LIGHT, "currentThemeMode");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: HomePage_Params) {
        if (params.inputValue !== undefined) {
            this.inputValue = params.inputValue;
        }
        if (params.calValue !== undefined) {
            this.calValue = params.calValue;
        }
        if (params.expressions !== undefined) {
            this.expressions = params.expressions;
        }
        if (params.isHistoryDialogShow !== undefined) {
            this.isHistoryDialogShow = params.isHistoryDialogShow;
        }
        if (params.historyList !== undefined) {
            this.historyList = params.historyList;
        }
    }
    updateStateVars(params: HomePage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__inputValue.purgeDependencyOnElmtId(rmElmtId);
        this.__calValue.purgeDependencyOnElmtId(rmElmtId);
        this.__isHistoryDialogShow.purgeDependencyOnElmtId(rmElmtId);
        this.__historyList.purgeDependencyOnElmtId(rmElmtId);
        this.__currentThemeMode.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__inputValue.aboutToBeDeleted();
        this.__calValue.aboutToBeDeleted();
        this.__isHistoryDialogShow.aboutToBeDeleted();
        this.__historyList.aboutToBeDeleted();
        this.__currentThemeMode.aboutToBeDeleted();
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
    /** 历史记录弹窗显示状态 */
    private __isHistoryDialogShow: ObservedPropertySimplePU<boolean>;
    get isHistoryDialogShow() {
        return this.__isHistoryDialogShow.get();
    }
    set isHistoryDialogShow(newValue: boolean) {
        this.__isHistoryDialogShow.set(newValue);
    }
    /** 历史记录列表（用于UI刷新） */
    private __historyList: ObservedPropertyObjectPU<Array<HistoryItem>>;
    get historyList() {
        return this.__historyList.get();
    }
    set historyList(newValue: Array<HistoryItem>) {
        this.__historyList.set(newValue);
    }
    /** 当前主题模式（监听 AppStorage 变化） */
    private __currentThemeMode: ObservedPropertyAbstractPU<number>;
    get currentThemeMode() {
        return this.__currentThemeMode.get();
    }
    set currentThemeMode(newValue: number) {
        this.__currentThemeMode.set(newValue);
    }
    /** 主题管理键名 */
    private static readonly THEME_KEY: string = 'currentThemeMode';
    /** 页面即将显示时初始化主题 */
    aboutToAppear(): void {
        // 初始化主题管理
        ThemeUtil.init();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.height(CommonConstants.FULL_PERCENT);
            Column.backgroundColor({ "id": 16777223, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            Column.bindSheet({ value: this.isHistoryDialogShow, changeEvent: newValue => { this.isHistoryDialogShow = newValue; } }, { builder: () => {
                    this.historySheetBuilder.call(this);
                } }, {
                height: { "id": 16777267, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" },
                backgroundColor: { "id": 16777262, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" },
                dragBar: true,
                showClose: true
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 顶部按钮区域：主题切换 + 历史记录
            Row.create();
            // 顶部按钮区域：主题切换 + 历史记录
            Row.width(CommonConstants.FULL_PERCENT);
            // 顶部按钮区域：主题切换 + 历史记录
            Row.margin({
                left: { "id": 16777236, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" },
                right: { "id": 16777236, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" },
                top: '20vp'
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 主题切换按钮（左上角）
            Button.createWithChild({ type: ButtonType.Circle });
            // 主题切换按钮（左上角）
            Button.width({ "id": 16777266, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            // 主题切换按钮（左上角）
            Button.height({ "id": 16777266, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            // 主题切换按钮（左上角）
            Button.backgroundColor({ "id": 16777277, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            // 主题切换按钮（左上角）
            Button.onClick(() => {
                // 切换主题
                ThemeUtil.toggleTheme();
            });
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 根据当前主题显示不同图标
            if (this.currentThemeMode === ThemeMode.LIGHT) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 浅色模式显示月亮图标（点击切换到深色）
                        Text.create('🌙');
                        // 浅色模式显示月亮图标（点击切换到深色）
                        Text.fontSize(20);
                    }, Text);
                    // 浅色模式显示月亮图标（点击切换到深色）
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 深色模式显示太阳图标（点击切换到浅色）
                        Text.create('☀️');
                        // 深色模式显示太阳图标（点击切换到浅色）
                        Text.fontSize(20);
                    }, Text);
                    // 深色模式显示太阳图标（点击切换到浅色）
                    Text.pop();
                });
            }
        }, If);
        If.pop();
        // 主题切换按钮（左上角）
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 历史记录按钮（右上角）
            Button.createWithChild({ type: ButtonType.Circle });
            // 历史记录按钮（右上角）
            Button.width({ "id": 16777266, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            // 历史记录按钮（右上角）
            Button.height({ "id": 16777266, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            // 历史记录按钮（右上角）
            Button.backgroundColor({ "id": 16777261, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            // 历史记录按钮（右上角）
            Button.onClick(() => {
                // 点击历史记录按钮，刷新列表并显示弹窗
                this.historyList = HistoryUtil.getHistoryList();
                this.isHistoryDialogShow = true;
            });
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 16777256, "type": 10003, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            Text.fontSize(12);
            Text.fontColor({ "id": 16777228, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
        }, Text);
        Text.pop();
        // 历史记录按钮（右上角）
        Button.pop();
        // 顶部按钮区域：主题切换 + 历史记录
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(CommonConstants.FULL_PERCENT);
            Column.height({ "id": 16777235, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            Column.alignItems(HorizontalAlign.End);
            Column.margin({
                right: { "id": 16777236, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" },
                top: { "id": 16777237, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" }
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ text: this.resultFormat(this.inputValue) });
            TextInput.height(CommonConstants.FULL_PERCENT);
            TextInput.fontSize((this.inputValue.length > CommonConstants.INPUT_LENGTH_MAX) ? { "id": 16777234, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" } : { "id": 16777233, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            TextInput.enabled(false);
            TextInput.fontColor({ "id": 16777275, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            TextInput.textAlign(TextAlign.End);
            TextInput.backgroundColor({ "id": 16777225, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
        }, TextInput);
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(CommonConstants.FULL_PERCENT);
            Column.height({ "id": 16777244, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            Column.alignItems(HorizontalAlign.End);
            Column.margin({
                right: { "id": 16777246, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" },
                bottom: { "id": 16777245, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" }
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.resultFormat(this.calValue));
            Text.fontSize({ "id": 16777234, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            Text.fontColor({ "id": 16777228, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
            Column.width(CommonConstants.FULL_PERCENT);
            Column.backgroundColor({ "id": 16777226, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.height(CommonConstants.FULL_PERCENT);
            Row.alignItems(VerticalAlign.Top);
            Row.margin({
                left: { "id": 16777241, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" },
                right: { "id": 16777242, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" }
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = (_item, columnItemIndex?: number) => {
                const columnItem = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.layoutWeight(1);
                    Column.margin({
                        top: { "id": 16777243, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" },
                        bottom: { "id": 16777240, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" }
                    });
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    ForEach.create();
                    const forEachItemGenFunction = (_item, keyItemIndex?: number) => {
                        const keyItem = _item;
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create();
                            Column.layoutWeight(((columnItemIndex === (keysModel.getPressKeys().length - 1)) &&
                                (keyItemIndex === (columnItem.length - 1))) ? CommonConstants.TWO : 1);
                            Column.width(CommonConstants.FULL_PERCENT);
                            Column.justifyContent(FlexAlign.Center);
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create();
                            Column.width({ "id": 16777239, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                            Column.height(((columnItemIndex === (keysModel.getPressKeys().length - 1)) &&
                                (keyItemIndex === (columnItem.length - 1))) ? { "id": 16777230, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" } : { "id": 16777238, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                            Column.borderWidth(1);
                            Column.borderColor({ "id": 16777222, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                            Column.borderRadius({ "id": 16777229, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                            Column.backgroundColor(((columnItemIndex === (keysModel.getPressKeys().length - 1)) &&
                                (keyItemIndex === (columnItem.length - 1))) ? { "id": 16777224, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" } : { "id": 16777276, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                            Column.alignItems(HorizontalAlign.Center);
                            Column.justifyContent(FlexAlign.Center);
                            Column.onClick(() => {
                                if (keyItem.flag === 0) {
                                    this.inputSymbol(keyItem.value);
                                }
                                else {
                                    this.inputNumber(keyItem.value);
                                }
                            });
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            If.create();
                            if (keyItem.flag === 0) {
                                this.ifElseBranchUpdateFunction(0, () => {
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Image.create(keyItem.source !== undefined ? keyItem.source : '');
                                        Image.width(keyItem.width);
                                        Image.height(keyItem.height);
                                    }, Image);
                                });
                            }
                            else {
                                this.ifElseBranchUpdateFunction(1, () => {
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(keyItem.value);
                                        Text.fontSize((keyItem.value === CommonConstants.DOTS) ? { "id": 16777232, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" } : { "id": 16777234, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                                        Text.width(keyItem.width);
                                        Text.height(keyItem.height);
                                    }, Text);
                                    Text.pop();
                                });
                            }
                        }, If);
                        If.pop();
                        Column.pop();
                        Column.pop();
                    };
                    this.forEachUpdateFunction(elmtId, columnItem, forEachItemGenFunction, (keyItem: PressKeysBean) => JSON.stringify(keyItem), true, false);
                }, ForEach);
                ForEach.pop();
                Column.pop();
            };
            this.forEachUpdateFunction(elmtId, keysModel.getPressKeys(), forEachItemGenFunction, (item: Array<Array<PressKeysBean>>) => JSON.stringify(item), true, false);
        }, ForEach);
        ForEach.pop();
        Row.pop();
        Column.pop();
        Column.pop();
    }
    /**
     * 历史记录弹窗内容构建器
     */
    historySheetBuilder(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 标题栏
            Row.create();
            // 标题栏
            Row.width('90%');
            // 标题栏
            Row.height(50);
            // 标题栏
            Row.margin({ top: 10 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 16777260, "type": 10003, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            Text.fontSize({ "id": 16777271, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor({ "id": 16777228, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel({ "id": 16777257, "type": 10003, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            Button.fontSize(14);
            Button.fontColor({ "id": 16777274, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
            Button.backgroundColor(Color.Transparent);
            Button.onClick(() => {
                // 清空历史记录
                HistoryUtil.clearHistory();
                this.historyList = [];
            });
        }, Button);
        Button.pop();
        // 标题栏
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 历史记录列表
            if (this.historyList.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 空状态提示
                        Column.create();
                        // 空状态提示
                        Column.width('100%');
                        // 空状态提示
                        Column.layoutWeight(1);
                        // 空状态提示
                        Column.justifyContent(FlexAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create({ "id": 16777259, "type": 10003, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                        Text.fontSize({ "id": 16777269, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                        Text.fontColor({ "id": 16777228, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                        Text.opacity(0.5);
                    }, Text);
                    Text.pop();
                    // 空状态提示
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 历史记录列表
                        List.create();
                        // 历史记录列表
                        List.width('90%');
                        // 历史记录列表
                        List.layoutWeight(1);
                        // 历史记录列表
                        List.margin({ top: 10 });
                        // 历史记录列表
                        List.divider({
                            strokeWidth: 1,
                            color: { "id": 16777263, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" },
                            startMargin: 10,
                            endMargin: 10
                        });
                    }, List);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = (_item, index: number) => {
                            const item = _item;
                            {
                                const itemCreation = (elmtId, isInitialRender) => {
                                    ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                                    ListItem.create(deepRenderFunction, true);
                                    if (!isInitialRender) {
                                        ListItem.pop();
                                    }
                                    ViewStackProcessor.StopGetAccessRecording();
                                };
                                const itemCreation2 = (elmtId, isInitialRender) => {
                                    ListItem.create(deepRenderFunction, true);
                                };
                                const deepRenderFunction = (elmtId, isInitialRender) => {
                                    itemCreation(elmtId, isInitialRender);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Column.create();
                                        Column.width('100%');
                                        Column.backgroundColor({ "id": 16777264, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                                        Column.borderRadius(10);
                                        Column.margin({ top: 5, bottom: 5 });
                                        Column.onClick(() => {
                                            // 点击历史记录，回填到输入框
                                            this.fillFromHistory(item.result);
                                            this.isHistoryDialogShow = false;
                                        });
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.width('100%');
                                        Row.height({ "id": 16777270, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                                        Row.padding({ left: 15, right: 15 });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 计算公式
                                        Text.create(item.expression);
                                        // 计算公式
                                        Text.fontSize({ "id": 16777269, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                                        // 计算公式
                                        Text.fontColor({ "id": 16777228, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                                        // 计算公式
                                        Text.layoutWeight(1);
                                    }, Text);
                                    // 计算公式
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 等号
                                        Text.create(' = ');
                                        // 等号
                                        Text.fontSize({ "id": 16777269, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                                        // 等号
                                        Text.fontColor({ "id": 16777228, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                                    }, Text);
                                    // 等号
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 计算结果
                                        Text.create(item.result);
                                        // 计算结果
                                        Text.fontSize({ "id": 16777269, "type": 10002, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                                        // 计算结果
                                        Text.fontColor({ "id": 16777265, "type": 10001, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
                                        // 计算结果
                                        Text.fontWeight(FontWeight.Bold);
                                    }, Text);
                                    // 计算结果
                                    Text.pop();
                                    Row.pop();
                                    Column.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.historyList, forEachItemGenFunction, (item: HistoryItem) => item.timestamp.toString(), true, false);
                    }, ForEach);
                    ForEach.pop();
                    // 历史记录列表
                    List.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
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
                });
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
        }
        else if (!secondLast) {
            this.expressions[len - 1] += value;
        }
        if (secondLast && CalculateUtil.isSymbol(secondLast)) {
            this.expressions[len - 1] += value;
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
        }
        else {
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
            this.calValue = this.resourceToString({ "id": 16777220, "type": 10003, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" });
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
        }
        catch (error) {
            Logger.error('[CalculateModel] getResourceString fail: ' + JSON.stringify(error));
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
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "HomePage";
    }
}
registerNamedRoute(() => new HomePage(undefined, {}), "", { bundleName: "com.example.simplecalculator", moduleName: "entry", pagePath: "pages/HomePage", pageFullPath: "entry/src/main/ets/pages/HomePage", integratedHsp: "false", moduleType: "followWithHap" });
