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

import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

/**
 * 屏幕断点枚举
 * SM: 小屏（手机竖屏、折叠屏折叠态）< 600vp
 * MD: 中屏（手机横屏、折叠屏展开态、小平板）600-840vp
 * LG: 大屏（平板、PC小窗口）840-1024vp
 * XL: 超大屏（PC大窗口）> 1024vp
 */
export enum Breakpoint {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl'
}

/**
 * 屏幕方向枚举
 */
export enum Orientation {
  PORTRAIT = 'portrait',   // 竖屏
  LANDSCAPE = 'landscape'  // 横屏
}

/**
 * 布局模式枚举
 */
export enum LayoutMode {
  COMPACT = 'compact',     // 单列紧凑布局（小屏）
  STANDARD = 'standard',   // 标准布局（中屏）
  EXPANDED = 'expanded',   // 扩展布局（大屏）
  WIDE = 'wide'           // 宽屏布局（超大屏）
}

/**
 * 响应式配置接口
 */
export interface ResponsiveConfig {
  /** 最小显示宽度（vp） */
  minWidth: number;
  /** 当前断点 */
  breakpoint: Breakpoint;
  /** 当前屏幕方向 */
  orientation: Orientation;
  /** 当前布局模式 */
  layoutMode: LayoutMode;
  /** 屏幕宽度（vp） */
  screenWidth: number;
  /** 屏幕高度（vp） */
  screenHeight: number;
}

/**
 * 响应式尺寸配置接口
 */
export interface ResponsiveSize {
  /** 按钮宽度 */
  buttonWidth: number;
  /** 按钮高度 */
  buttonHeight: number;
  /** 按钮圆角 */
  buttonRadius: number;
  /** 按钮间距 */
  buttonSpacing: number;
  /** 输入框高度 */
  inputHeight: number;
  /** 输入框字号 */
  inputFontSize: number;
  /** 结果字号 */
  resultFontSize: number;
  /** 按钮字号 */
  buttonFontSize: number;
  /** 内边距 */
  padding: number;
  /** 外边距 */
  margin: number;
}

/**
 * 响应式适配工具类
 * 负责监听屏幕尺寸变化、计算响应式尺寸、提供布局模式判断
 */
class ResponsiveUtil {
  /** 断点阈值（单位：vp） */
  private static readonly BREAKPOINT_SM = 600;
  private static readonly BREAKPOINT_MD = 840;
  private static readonly BREAKPOINT_LG = 1024;

  /** 最小显示宽度（单位：vp） */
  private static readonly MIN_WIDTH = 280;

  /** 最小可点击尺寸（单位：vp，遵循 HarmonyOS 设计规范） */
  private static readonly MIN_TOUCH_SIZE = 44;

  /** 当前响应式配置 */
  private currentConfig: ResponsiveConfig = {
    minWidth: ResponsiveUtil.MIN_WIDTH,
    breakpoint: Breakpoint.SM,
    orientation: Orientation.PORTRAIT,
    layoutMode: LayoutMode.COMPACT,
    screenWidth: 360,
    screenHeight: 640
  };

  /** 屏幕尺寸变化监听器列表 */
  private listeners: Array<(config: ResponsiveConfig) => void> = [];

  /** display 对象 */
  private display: display.Display | null = null;

  /**
   * 初始化响应式适配
   * 在应用启动时调用
   */
  init(context: common.UIAbilityContext): void {
    try {
      // 获取默认 display
      this.display = display.getDefaultDisplaySync(context);
      
      // 初始化配置
      this.updateConfig();
      
      // 监听屏幕尺寸变化
      this.display.on('change', () => {
        this.updateConfig();
        this.notifyListeners();
      });
      
      // 将初始配置存入 AppStorage
      AppStorage.setOrCreate('responsiveConfig', this.currentConfig);
    } catch (error) {
      console.error('[ResponsiveUtil] init failed:', JSON.stringify(error));
    }
  }

  /**
   * 更新当前配置
   */
  private updateConfig(): void {
    if (!this.display) {
      return;
    }

    const width = this.display.width / this.display.densityPixels; // 转换为 vp
    const height = this.display.height / this.display.densityPixels;

    this.currentConfig.screenWidth = width;
    this.currentConfig.screenHeight = height;
    this.currentConfig.breakpoint = this.calculateBreakpoint(width);
    this.currentConfig.orientation = width > height ? Orientation.LANDSCAPE : Orientation.PORTRAIT;
    this.currentConfig.layoutMode = this.calculateLayoutMode(width);
  }

  /**
   * 计算断点
   */
  private calculateBreakpoint(width: number): Breakpoint {
    if (width < ResponsiveUtil.BREAKPOINT_SM) {
      return Breakpoint.SM;
    } else if (width < ResponsiveUtil.BREAKPOINT_MD) {
      return Breakpoint.MD;
    } else if (width < ResponsiveUtil.BREAKPOINT_LG) {
      return Breakpoint.LG;
    } else {
      return Breakpoint.XL;
    }
  }

  /**
   * 计算布局模式
   */
  private calculateLayoutMode(width: number): LayoutMode {
    if (width < ResponsiveUtil.BREAKPOINT_SM) {
      return LayoutMode.COMPACT;
    } else if (width < ResponsiveUtil.BREAKPOINT_MD) {
      return LayoutMode.STANDARD;
    } else if (width < ResponsiveUtil.BREAKPOINT_LG) {
      return LayoutMode.EXPANDED;
    } else {
      return LayoutMode.WIDE;
    }
  }

  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    // 更新 AppStorage
    AppStorage.setOrCreate('responsiveConfig', this.currentConfig);
    
    // 通知监听器
    this.listeners.forEach(listener => {
      listener(this.currentConfig);
    });
  }

  /**
   * 添加屏幕尺寸变化监听器
   */
  addListener(listener: (config: ResponsiveConfig) => void): void {
    this.listeners.push(listener);
  }

  /**
   * 移除屏幕尺寸变化监听器
   */
  removeListener(listener: (config: ResponsiveConfig) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  /**
   * 获取当前配置
   */
  getConfig(): ResponsiveConfig {
    return this.currentConfig;
  }

  /**
   * 获取当前断点
   */
  getBreakpoint(): Breakpoint {
    return this.currentConfig.breakpoint;
  }

  /**
   * 获取当前屏幕方向
   */
  getOrientation(): Orientation {
    return this.currentConfig.orientation;
  }

  /**
   * 获取当前布局模式
   */
  getLayoutMode(): LayoutMode {
    return this.currentConfig.layoutMode;
  }

  /**
   * 获取屏幕宽度（vp）
   */
  getScreenWidth(): number {
    return this.currentConfig.screenWidth;
  }

  /**
   * 获取屏幕高度（vp）
   */
  getScreenHeight(): number {
    return this.currentConfig.screenHeight;
  }

  /**
   * 判断是否为小屏
   */
  isSmallScreen(): boolean {
    return this.currentConfig.breakpoint === Breakpoint.SM;
  }

  /**
   * 判断是否为中屏
   */
  isMediumScreen(): boolean {
    return this.currentConfig.breakpoint === Breakpoint.MD;
  }

  /**
   * 判断是否为大屏
   */
  isLargeScreen(): boolean {
    return this.currentConfig.breakpoint === Breakpoint.LG ||
           this.currentConfig.breakpoint === Breakpoint.XL;
  }

  /**
   * 判断是否为横屏
   */
  isLandscape(): boolean {
    return this.currentConfig.orientation === Orientation.LANDSCAPE;
  }

  /**
   * 判断是否为竖屏
   */
  isPortrait(): boolean {
    return this.currentConfig.orientation === Orientation.PORTRAIT;
  }

  /**
   * 判断是否为极窄屏幕（需要显示友好提示）
   */
  isNarrowScreen(): boolean {
    return this.currentConfig.screenWidth < ResponsiveUtil.MIN_WIDTH;
  }

  /**
   * 获取响应式尺寸配置
   * 根据当前屏幕宽度计算合适的尺寸
   */
  getResponsiveSize(): ResponsiveSize {
    const width = this.currentConfig.screenWidth;
    const breakpoint = this.currentConfig.breakpoint;

    // 基础尺寸配置
    let baseSize: ResponsiveSize;

    switch (breakpoint) {
      case Breakpoint.SM:
        // 小屏：紧凑布局
        baseSize = {
          buttonWidth: Math.max(70, width * 0.22),  // 保证最小可点击尺寸
          buttonHeight: Math.max(60, width * 0.12),
          buttonRadius: Math.max(12, width * 0.03),
          buttonSpacing: Math.max(6, width * 0.015),
          inputHeight: Math.max(80, width * 0.22),
          inputFontSize: Math.max(32, width * 0.09),
          resultFontSize: Math.max(20, width * 0.055),
          buttonFontSize: Math.max(18, width * 0.05),
          padding: Math.max(8, width * 0.02),
          margin: Math.max(12, width * 0.03)
        };
        break;

      case Breakpoint.MD:
        // 中屏：标准布局
        baseSize = {
          buttonWidth: Math.max(80, width * 0.18),
          buttonHeight: Math.max(65, width * 0.1),
          buttonRadius: Math.max(16, width * 0.025),
          buttonSpacing: Math.max(10, width * 0.012),
          inputHeight: Math.max(100, width * 0.15),
          inputFontSize: Math.max(40, width * 0.06),
          resultFontSize: Math.max(24, width * 0.035),
          buttonFontSize: Math.max(22, width * 0.03),
          padding: Math.max(12, width * 0.015),
          margin: Math.max(16, width * 0.02)
        };
        break;

      case Breakpoint.LG:
        // 大屏：扩展布局
        baseSize = {
          buttonWidth: Math.max(90, width * 0.12),
          buttonHeight: Math.max(70, width * 0.08),
          buttonRadius: Math.max(20, width * 0.02),
          buttonSpacing: Math.max(12, width * 0.01),
          inputHeight: Math.max(120, width * 0.12),
          inputFontSize: Math.max(48, width * 0.045),
          resultFontSize: Math.max(28, width * 0.025),
          buttonFontSize: Math.max(24, width * 0.022),
          padding: Math.max(16, width * 0.012),
          margin: Math.max(20, width * 0.015)
        };
        break;

      case Breakpoint.XL:
        // 超大屏：宽屏布局
        baseSize = {
          buttonWidth: Math.max(100, width * 0.1),
          buttonHeight: Math.max(75, width * 0.07),
          buttonRadius: Math.max(24, width * 0.018),
          buttonSpacing: Math.max(14, width * 0.008),
          inputHeight: Math.max(140, width * 0.1),
          inputFontSize: Math.max(56, width * 0.04),
          resultFontSize: Math.max(32, width * 0.022),
          buttonFontSize: Math.max(28, width * 0.02),
          padding: Math.max(20, width * 0.01),
          margin: Math.max(24, width * 0.012)
        };
        break;

      default:
        // 默认使用小屏配置
        baseSize = {
          buttonWidth: 70,
          buttonHeight: 60,
          buttonRadius: 12,
          buttonSpacing: 8,
          inputHeight: 86,
          inputFontSize: 32,
          resultFontSize: 20,
          buttonFontSize: 18,
          padding: 10,
          margin: 15
        };
    }

    // 确保按钮尺寸不小于最小可点击尺寸
    baseSize.buttonWidth = Math.max(baseSize.buttonWidth, ResponsiveUtil.MIN_TOUCH_SIZE);
    baseSize.buttonHeight = Math.max(baseSize.buttonHeight, ResponsiveUtil.MIN_TOUCH_SIZE);

    return baseSize;
  }

  /**
   * 计算自适应字号
   * 根据内容长度和可用宽度动态调整字号
   * @param content 内容文本
   * @param maxWidth 最大宽度（vp）
   * @param maxFontSize 最大字号（fp）
   * @param minFontSize 最小字号（fp）
   */
  calculateAdaptiveFontSize(
    content: string,
    maxWidth: number,
    maxFontSize: number,
    minFontSize: number = 16
  ): number {
    if (!content || content.length === 0) {
      return maxFontSize;
    }

    // 估算字符宽度（假设平均字符宽度为字号的 0.6 倍）
    const avgCharWidth = maxFontSize * 0.6;
    const contentWidth = content.length * avgCharWidth;

    // 如果内容宽度小于最大宽度，使用最大字号
    if (contentWidth <= maxWidth) {
      return maxFontSize;
    }

    // 计算缩放比例
    const scale = maxWidth / contentWidth;
    let fontSize = maxFontSize * scale;

    // 确保字号不小于最小值
    fontSize = Math.max(fontSize, minFontSize);

    return Math.floor(fontSize);
  }

  /**
   * 获取列数
   * 根据屏幕宽度返回合适的列数
   */
  getColumnCount(): number {
    const layoutMode = this.currentConfig.layoutMode;
    
    switch (layoutMode) {
      case LayoutMode.COMPACT:
        return 1;  // 小屏单列
      case LayoutMode.STANDARD:
        return this.isLandscape() ? 2 : 1;  // 中屏横屏双列，竖屏单列
      case LayoutMode.EXPANDED:
      case LayoutMode.WIDE:
        return 2;  // 大屏双列
      default:
        return 1;
    }
  }

  /**
   * 获取按键区域宽度比例
   */
  getKeypadWidthRatio(): number {
    const columnCount = this.getColumnCount();
    
    if (columnCount === 1) {
      return 1.0;  // 单列占满宽度
    } else {
      return 0.6;  // 双列时按键区域占 60%
    }
  }

  /**
   * 获取历史记录区域宽度比例
   */
  getHistoryWidthRatio(): number {
    const columnCount = this.getColumnCount();
    
    if (columnCount === 1) {
      return 0.0;  // 单列不显示历史记录区域
    } else {
      return 0.4;  // 双列时历史记录区域占 40%
    }
  }
}

export default new ResponsiveUtil();
