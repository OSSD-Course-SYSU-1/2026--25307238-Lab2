import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { UIContext, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import FloatWindowUtil from '../common/util/FloatWindowUtil';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // 将 ApplicationContext 存入 AppStorage，供主题管理使用
    AppStorage.setOrCreate('appContext', this.context.getApplicationContext());
    // 存储 UIAbilityContext 供悬浮窗使用
    AppStorage.setOrCreate('uiAbilityContext', this.context);
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    // 销毁悬浮窗
    FloatWindowUtil.destroyFloatWindow();
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    
    // 将 WindowStage 存入 AppStorage，供悬浮窗功能使用
    AppStorage.setOrCreate('windowStage', windowStage);
    // 初始化悬浮窗工具类的 WindowStage
    FloatWindowUtil.setWindowStage(windowStage);
    
    windowStage.loadContent('pages/HomePage', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');

      let uiContext:  UIContext | undefined = windowStage.getMainWindowSync().getUIContext()
      AppStorage.setOrCreate('uiContext', uiContext);
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
