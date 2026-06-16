import type AbilityConstant from "@ohos:app.ability.AbilityConstant";
import UIAbility from "@ohos:app.ability.UIAbility";
import type Want from "@ohos:app.ability.Want";
import type { UIContext } from "@ohos:arkui.UIContext";
import type window from "@ohos:window";
import hilog from "@ohos:hilog";
import FloatWindowUtil from "@bundle:com.example.simplecalculator/entry/ets/common/util/FloatWindowUtil";
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
            let uiContext: UIContext | undefined = windowStage.getMainWindowSync().getUIContext();
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
