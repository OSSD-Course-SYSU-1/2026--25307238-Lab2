import ConfigurationConstant from "@ohos:app.ability.ConfigurationConstant";
import type common from "@ohos:app.ability.common";
/**
 * 主题模式枚举
 */
export enum ThemeMode {
    /** 浅色模式 */
    LIGHT = 0,
    /** 深色模式 */
    DARK = 1
}
/**
 * 主题管理工具类
 * 负责管理应用的深浅色主题切换
 */
class ThemeUtil {
    /** 当前主题模式，默认浅色模式 */
    private currentMode: ThemeMode = ThemeMode.LIGHT;
    /** AppStorage 中的主题键名 */
    public static readonly THEME_KEY: string = 'currentThemeMode';
    /** ApplicationContext 引用 */
    private applicationContext: common.ApplicationContext | null = null;
    /**
     * 初始化主题管理
     * 在应用启动时调用，设置初始主题
     */
    init(): void {
        // 从 AppStorage 获取 ApplicationContext
        this.applicationContext = AppStorage.get<common.ApplicationContext>('appContext') ?? null;
        // 将初始主题存入 AppStorage
        AppStorage.setOrCreate(ThemeUtil.THEME_KEY, this.currentMode);
    }
    /**
     * 应用当前主题到系统
     * 使用 ApplicationContext.setColorMode 切换系统主题
     */
    private applyTheme(): void {
        if (this.applicationContext) {
            // 使用 setColorMode 切换系统主题
            // 这样 $r() 资源引用会自动选择 dark 目录的资源
            if (this.currentMode === ThemeMode.DARK) {
                this.applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
            }
            else {
                this.applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
            }
        }
    }
    /**
     * 获取当前主题模式
     * @returns 当前主题模式
     */
    getCurrentMode(): ThemeMode {
        return this.currentMode;
    }
    /**
     * 判断是否为深色模式
     * @returns 是否为深色模式
     */
    isDarkMode(): boolean {
        return this.currentMode === ThemeMode.DARK;
    }
    /**
     * 切换主题模式
     * 浅色 <-> 深色
     */
    toggleTheme(): void {
        if (this.currentMode === ThemeMode.LIGHT) {
            this.currentMode = ThemeMode.DARK;
        }
        else {
            this.currentMode = ThemeMode.LIGHT;
        }
        // 更新 AppStorage 中的值，触发 UI 刷新
        AppStorage.set(ThemeUtil.THEME_KEY, this.currentMode);
        // 应用主题到系统
        this.applyTheme();
    }
    /**
     * 设置指定主题模式
     * @param mode 目标主题模式
     */
    setTheme(mode: ThemeMode): void {
        if (this.currentMode !== mode) {
            this.currentMode = mode;
            AppStorage.set(ThemeUtil.THEME_KEY, this.currentMode);
            this.applyTheme();
        }
    }
}
export default new ThemeUtil();
