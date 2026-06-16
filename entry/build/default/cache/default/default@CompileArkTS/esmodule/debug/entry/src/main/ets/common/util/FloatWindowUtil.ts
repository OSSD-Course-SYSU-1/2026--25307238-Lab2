import type window from "@ohos:window";
import type common from "@ohos:app.ability.common";
import type { BusinessError } from "@ohos:base";
import hilog from "@ohos:hilog";
const TAG = 'FloatWindowUtil';
const DOMAIN = 0x0000;
/**
 * 悬浮窗管理工具类
 * 使用子窗口(createSubWindow)创建应用内悬浮窗
 *
 * 注意：手机上子窗口只能在主窗口内部显示
 */
class FloatWindowUtil {
    private static instance: FloatWindowUtil;
    private floatWindow: window.Window | null = null;
    private windowStage: window.WindowStage | null = null;
    private isShowing: boolean = false;
    // 悬浮窗尺寸 (vp)
    private readonly DEFAULT_WIDTH: number = 280;
    private readonly DEFAULT_HEIGHT: number = 400;
    // 悬浮窗名称
    private readonly WINDOW_NAME: string = 'floatCalculatorWindow';
    private constructor() { }
    static getInstance(): FloatWindowUtil {
        if (!FloatWindowUtil.instance) {
            FloatWindowUtil.instance = new FloatWindowUtil();
        }
        return FloatWindowUtil.instance;
    }
    setWindowStage(windowStage: window.WindowStage): void {
        this.windowStage = windowStage;
        hilog.info(DOMAIN, TAG, 'WindowStage initialized');
    }
    async showFloatWindow(context: common.UIAbilityContext): Promise<boolean> {
        hilog.info(DOMAIN, TAG, '=== showFloatWindow START ===');
        hilog.info(DOMAIN, TAG, 'isShowing: %{public}s', String(this.isShowing));
        hilog.info(DOMAIN, TAG, 'windowStage: %{public}s', this.windowStage ? 'not null' : 'null');
        // 如果已显示，直接返回
        if (this.isShowing && this.floatWindow) {
            hilog.info(DOMAIN, TAG, 'Window already showing');
            return true;
        }
        if (!this.windowStage) {
            hilog.error(DOMAIN, TAG, 'ERROR: WindowStage is null!');
            return false;
        }
        try {
            // Step 1: 创建子窗口
            hilog.info(DOMAIN, TAG, 'Step 1: Creating sub window...');
            this.floatWindow = await this.windowStage.createSubWindow(this.WINDOW_NAME);
            hilog.info(DOMAIN, TAG, 'Step 1: SUCCESS - window created');
            // Step 2: 获取主窗口尺寸
            hilog.info(DOMAIN, TAG, 'Step 2: Getting main window info...');
            const mainWindow = this.windowStage.getMainWindowSync();
            const mainRect = mainWindow.getWindowProperties().windowRect;
            hilog.info(DOMAIN, TAG, 'Step 2: Main window rect: [%{public}d, %{public}d, %{public}d x %{public}d]', mainRect.left, mainRect.top, mainRect.width, mainRect.height);
            // Step 3: 设置窗口位置和大小
            hilog.info(DOMAIN, TAG, 'Step 3: Setting window position and size...');
            const posX = 20;
            const posY = 80;
            await this.floatWindow.moveWindowTo(posX, posY);
            await this.floatWindow.resize(this.DEFAULT_WIDTH, this.DEFAULT_HEIGHT);
            hilog.info(DOMAIN, TAG, 'Step 3: SUCCESS - pos=(%{public}d, %{public}d), size=%{public}dx%{public}d', posX, posY, this.DEFAULT_WIDTH, this.DEFAULT_HEIGHT);
            // Step 4: 设置窗口属性
            hilog.info(DOMAIN, TAG, 'Step 4: Setting window properties...');
            // 设置背景色
            this.floatWindow.setWindowBackgroundColor('#FFFFFF');
            // 设置窗口可获取焦点
            await this.floatWindow.setWindowFocusable(true);
            // 设置窗口可触摸
            await this.floatWindow.setWindowTouchable(true);
            hilog.info(DOMAIN, TAG, 'Step 4: SUCCESS - properties set');
            // Step 5: 加载页面内容
            hilog.info(DOMAIN, TAG, 'Step 5: Loading UI content...');
            await this.floatWindow.setUIContent('pages/FloatCalculatorPage');
            hilog.info(DOMAIN, TAG, 'Step 5: SUCCESS - UI content loaded');
            // Step 6: 显示窗口
            hilog.info(DOMAIN, TAG, 'Step 6: Showing window...');
            await this.floatWindow.showWindow();
            this.isShowing = true;
            hilog.info(DOMAIN, TAG, 'Step 6: SUCCESS - window shown');
            hilog.info(DOMAIN, TAG, '=== showFloatWindow SUCCESS ===');
            return true;
        }
        catch (error) {
            const err = error as BusinessError;
            hilog.error(DOMAIN, TAG, '=== showFloatWindow FAILED ===');
            hilog.error(DOMAIN, TAG, 'Error code: %{public}d', err.code);
            hilog.error(DOMAIN, TAG, 'Error message: %{public}s', err.message);
            // 清理
            this.floatWindow = null;
            this.isShowing = false;
            return false;
        }
    }
    async destroyFloatWindow(): Promise<void> {
        hilog.info(DOMAIN, TAG, 'destroyFloatWindow called');
        if (!this.floatWindow) {
            return;
        }
        try {
            await this.floatWindow.destroyWindow();
            this.floatWindow = null;
            this.isShowing = false;
            hilog.info(DOMAIN, TAG, 'Destroy SUCCESS');
        }
        catch (error) {
            const err = error as BusinessError;
            hilog.error(DOMAIN, TAG, 'Destroy FAILED: code=%{public}d, msg=%{public}s', err.code, err.message);
        }
    }
    async moveWindowTo(x: number, y: number): Promise<void> {
        if (!this.floatWindow) {
            return;
        }
        try {
            await this.floatWindow.moveWindowTo(x, y);
        }
        catch (error) {
            hilog.error(DOMAIN, TAG, 'Move failed');
        }
    }
    isFloatWindowShowing(): boolean {
        return this.isShowing;
    }
    getFloatWindow(): window.Window | null {
        return this.floatWindow;
    }
}
export default FloatWindowUtil.getInstance();
