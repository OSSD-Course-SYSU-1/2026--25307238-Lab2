import { PressKeysBean } from "@bundle:com.example.simplecalculator/entry/ets/viewmodel/PressKeysItem";
export class PressKeysBeanViewModel {
    /**
     * Key array data.
     * 按行排列，每行包含一组按键
     */
    getPressKeys(): Array<Array<PressKeysBean>> {
        return [
            // 第1行：C, ÷, ×, ⌫
            [
                new PressKeysBean(0, '32vp', '32vp', 'clean', { "id": 16777248, "type": 20000, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" }),
                new PressKeysBean(0, '32vp', '32vp', 'div', { "id": 16777279, "type": 20000, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" }),
                new PressKeysBean(0, '32vp', '32vp', 'mul', { "id": 16777282, "type": 20000, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" }),
                new PressKeysBean(0, '30.48vp', '20vp', 'del', { "id": 16777249, "type": 20000, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" })
            ],
            // 第2行：7, 8, 9, -
            [
                new PressKeysBean(1, '19vp', '43vp', '7'),
                new PressKeysBean(1, '19vp', '43vp', '8'),
                new PressKeysBean(1, '19vp', '43vp', '9'),
                new PressKeysBean(0, '24vp', '24vp', 'min', { "id": 16777281, "type": 20000, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" })
            ],
            // 第3行：4, 5, 6, +
            [
                new PressKeysBean(1, '19vp', '43vp', '4'),
                new PressKeysBean(1, '19vp', '43vp', '5'),
                new PressKeysBean(1, '19vp', '43vp', '6'),
                new PressKeysBean(0, '32vp', '32vp', 'add', { "id": 16777278, "type": 20000, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" })
            ],
            // 第4行：1, 2, 3, =
            [
                new PressKeysBean(1, '19vp', '43vp', '1'),
                new PressKeysBean(1, '19vp', '43vp', '2'),
                new PressKeysBean(1, '19vp', '43vp', '3'),
                new PressKeysBean(0, '32vp', '32vp', 'equ', { "id": 16777280, "type": 20000, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" })
            ],
            // 第5行：%, 0, ., =
            [
                new PressKeysBean(1, '25vp', '43vp', '%'),
                new PressKeysBean(1, '19vp', '43vp', '0'),
                new PressKeysBean(1, '19vp', '43vp', '.'),
                new PressKeysBean(0, '32vp', '32vp', 'equ', { "id": 16777280, "type": 20000, params: [], "bundleName": "com.example.simplecalculator", "moduleName": "entry" })
            ]
        ];
    }
}
let keysModel = new PressKeysBeanViewModel();
export default keysModel as PressKeysBeanViewModel;
