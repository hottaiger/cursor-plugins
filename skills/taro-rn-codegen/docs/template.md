# 模板规范（Template）

## 1. 文件头部结构

```tsx
import { View, Text, Image } from '@tarojs/components';
import { useState, useEffect, useMemo, useCallback } from 'react';
import './index.less';
```

- Taro 组件从 `@tarojs/components` 引入
- React hooks 从 `react` 引入
- 样式文件最后引入

## 2. 组件定义方式

### 函数组件（推荐）

```tsx
interface IProps {
  title: string;
  count?: number;
  onClose?: () => void;
}

const MyComponent = ({ title, count = 0, onClose }: IProps) => {
  return (
    <View className="my-component">
      <Text className="my-component__title">{title}</Text>
    </View>
  );
};

export default MyComponent;
```

- 使用 `interface IProps` 定义 props 类型
- 可选 props 用 `?` 标记，并在解构时提供默认值
- 默认导出组件

### FC 类型（适用于需要明确 FC 类型的场景）

```tsx
import { FC } from 'react'

const MyComponent: FC<IProps> = ({ title }) => { ... }
```

## 3. 基础标签映射

| 场景      | 使用组件                                         |
| --------- | ------------------------------------------------ |
| 容器/布局 | `<View>`                                         |
| 文本      | `<Text>`                                         |
| 图片      | `<Image>`                                        |
| 输入框    | `<Input>`                                        |
| 多行输入  | `<Textarea>`                                     |
| 按钮      | `<View onClick={}>` 或 `<Button>`                |
| 滚动容器  | `<ScrollView scrollY>` 或 `<ScrollView scrollX>` |

> 所有文本必须包裹在 `<Text>` 中，不能直接写在 `<View>` 里。

## 4. 条件渲染

```tsx
// 简单条件
{
  visible && <View className="popup">...</View>;
}

// 三元
{
  isLoading ? <Skeleton /> : <Content />;
}

// 多分支用函数
const renderContent = () => {
  switch (status) {
    case 'loading':
      return <Skeleton />;
    case 'error':
      return <PageError />;
    case 'success':
      return <Content />;
    default:
      return null;
  }
};
```

## 5. 列表渲染

```tsx
{
  list.map((item, index) => (
    <View key={item.id} className="list__item">
      <Text>{item.name}</Text>
    </View>
  ));
}
```

## 6. 事件处理

```tsx
// 点击
<View onClick={handleClick}>

// 阻止冒泡
<View onClick={(e) => { e.stopPropagation(); handleClick() }}>

// 内联简单逻辑
<View onClick={() => setVisible(false)}>
```

## 7. 渐变背景

RN 不支持 CSS 渐变，必须用 `LinearGradient` 组件：

```tsx
import LinearGradient from '@/components/linear-gradient'

<LinearGradient
  colors={['#FF4D18', '#FF6234']}
  start={{ x: 0, y: 0 }}
  end={{ x: 1, y: 0 }}
  locations={[0, 1]}
>
  <View>内容</View>
</LinearGradient>

// 角度模式（对应 CSS to bottom）
<LinearGradient
  colors={['rgba(255,255,255,0)', '#fff']}
  useAngle
  angle={270}
  locations={[0, 1]}
>
  <View>内容</View>
</LinearGradient>
```

## 8. 图片背景

```tsx
// RN 不支持 background-image，用 Image 绝对定位模拟
<View className="banner">
  <Image src={bgImg} className="banner__bg" mode="aspectFill" />
  <View className="banner__content">...</View>
</View>
```

## 9. 曝光埋点

```tsx
import { TrackerBeseenInView } from '@/components/tracker-beseen';

<TrackerBeseenInView
  trackerParams={{
    tracking_type: 'beseen',
    moduleId: 'module-name',
  }}
>
  <View>内容</View>
</TrackerBeseenInView>;
```

## 10. 弹窗组件

```tsx
import PopupHeader from '@/components/popup-header';

<PopupHeader
  visible={visible}
  position="bottom"
  onClose={() => setVisible(false)}
  title="标题"
  buttonName="知道了"
  onBtnClick={() => setVisible(false)}
  style={{}}
>
  <View>弹窗内容</View>
</PopupHeader>;
```

## 11. className 动态拼接

```tsx
// 简单拼接
<View className={`my-comp ${isActive ? 'my-comp--active' : ''}`}>

// 多条件用 classnames 库
import classNames from 'classnames'
<View className={classNames('my-comp', { 'my-comp--active': isActive, 'my-comp--disabled': disabled })}>
```

## 12. 平台差异处理

```tsx
// 运行时判断
if (TARO_ENV === 'rn') {
  // RN 专属逻辑
}

// 条件引入（RN 专属模块）
let GRNNativeAPI: any;
if (TARO_ENV === 'rn') {
  GRNNativeAPI = require('grn-core/lib/bridge/nativeApi').GRNNativeAPI;
}
```
