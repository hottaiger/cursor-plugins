# 逻辑规范（Script）

## 1. 组件逻辑结构顺序

```tsx
const MyComponent = ({ prop1, prop2 }: IProps) => {
  // 1. store 取值
  const clueId = usePageStore((state: PageStoreState) => state.commonSlice.clueId)

  // 2. 本地 state
  const [visible, setVisible] = useState(false)

  // 3. service hooks
  const { runAsyncXxxService } = useXxxService()

  // 4. useMemo / useCallback
  const computedValue = useMemo(() => { ... }, [dep])
  const handleClick = useCallback(() => { ... }, [dep])

  // 5. useEffect
  useEffect(() => { ... }, [dep])

  // 6. 普通函数（不需要 useCallback 的简单处理）
  const handleClose = () => setVisible(false)

  // 7. 渲染
  return (...)
}
```

## 2. State 管理

### 本地 state（useState）

```tsx
const [visible, setVisible] = useState(false);
const [data, setData] = useState<DataType | null>(null);
const [list, setList] = useState<Item[]>([]);
```

### 全局 store（zustand）

```tsx
import usePageStore, { PageStoreState } from '@/pages/index/store';

// 读取
const clueId = usePageStore((state: PageStoreState) => state.commonSlice.clueId);
const isNewEnergy = usePageStore((state: PageStoreState) => state.carSlice.isNewEnergy);

// 写入
const setOtherSlice = usePageStore((state: PageStoreState) => state.otherSlice.setOtherSlice);
setOtherSlice({ guaziCityId: 123 });
```

### 新建 store slice

```ts
// src/pages/index/store/mySlice.ts
import { produce } from 'immer';

export interface MySliceState {
  /** 字段说明 */
  value: string;
  setMySlice: (payload: Partial<Omit<MySliceState, 'setMySlice'>>) => void;
}

const createMySlice = (set): MySliceState => ({
  value: '',
  setMySlice: (payload) => {
    set(
      produce((state: any) => {
        Object.assign(state.mySlice, payload);
      }),
    );
  },
});

export default createMySlice;
```

然后在 `store/index.tsx` 的 `PageStoreState` 和 `createPageStore` 中注册。

## 3. Service Hook

```ts
// src/pages/index/service/useMyService.ts
import { useRequest } from 'ahooks';
import { useMemoizedFn } from 'ahooks';
import apiM from '@/network/api-m';

export const useMyService = () => {
  const fetchData = useMemoizedFn(async (params: { clueId: string }) => {
    const res = await apiM.request('myApiKey', params);
    return res;
  });

  const { runAsync } = useRequest(fetchData, {
    manual: true,
  });

  return { runAsyncMyService: runAsync };
};
```

规则：

- 使用 `ahooks` 的 `useRequest`，`manual: true` 手动触发
- 用 `useMemoizedFn` 包裹请求函数，避免重复创建
- 返回值命名为 `runAsync{ServiceName}`
- 接口 key 在 `apiM.request` 第一个参数传入

## 4. 埋点

```ts
import { sendTrack } from '@guazi-fe/cross-utils';

// 点击埋点
sendTrack({
  tracking_type: 'click',
  moduleId: 'module-name-button',
});

// 曝光埋点（组件内）
sendTrack({
  tracking_type: 'beseen',
  moduleId: 'module-name',
});
```

moduleId 统一在 `@/pages/index/utils/moduleId.ts` 中维护：

```ts
// 先查找是否已有对应 key，没有再新增
export const myModuleId = {
  myButton: 'my-module-button',
};
```

## 5. 页面跳转

```ts
import { goNewPage } from '@/utils/navigate';

// 带埋点跳转
goNewPage(url, {
  sendTrack: true,
  track: { moduleId: 'module-name' },
});

// 不带埋点
goNewPage(url);
```

跳转函数统一在 `@/pages/index/utils/navigate.ts` 中封装，先查找是否已有对应函数。

## 6. 登录校验

```ts
import { checkLoginAndExec } from '@/utils/check-login';

checkLoginAndExec({
  callback: async () => {
    // 登录后执行的逻辑
  },
});
```

## 7. useMemo / useCallback 使用原则

```tsx
// useMemo：计算开销较大，或需要稳定引用的派生值
const filteredList = useMemo(() => {
  return list.filter((item) => item.active);
}, [list]);

// useCallback：传给子组件的回调，或在 useEffect 依赖中使用的函数
const handleSubmit = useCallback(() => {
  runAsyncService({ clueId });
}, [clueId, runAsyncService]);

// 简单的内联处理不需要 useCallback
const handleClose = () => setVisible(false);
```

## 8. useEffect 规范

```tsx
// 初始化（mounted）
useEffect(() => {
  fetchData()
}, [])

// 依赖变化
useEffect(() => {
  if (!clueId) return
  fetchData(clueId)
}, [clueId])

// 清理副作用
useEffect(() => {
  const listener = GRNNativeAPI.onSomeEvent((res) => { ... })
  return () => {
    listener?.remove?.()
  }
}, [])

// Taro 事件中心
useEffect(() => {
  Taro.eventCenter.on('eventName', handler)
  return () => {
    Taro.eventCenter.off('eventName')
  }
}, [clueId])
```

## 9. TypeScript 规范

```ts
// interface 命名：IProps（组件 props）、普通接口直接语义命名
interface IProps {
  title: string;
  count?: number;
}

// 类型断言用 as，避免 any（必要时加注释说明）
const data = res as MyDataType;

// 枚举用 type union 替代 enum
type Status = 'loading' | 'success' | 'error';

// 泛型
const [data, setData] = useState<DetailResponse | null>(null);
```

## 10. 错误处理

```ts
// service 调用统一 try/catch 或 .catch
runAsyncService({ clueId })
  .then((res) => {
    setData(res);
  })
  .catch((e) => {
    console.error('🚀 ~ serviceName ~ e:', e);
  });

// 上报异常
import { sendException } from '@guazi-fe/cross-utils';
sendException({
  code: err?.data?.code || -1,
  uri: 'apiName',
  message: JSON.stringify(err),
  err,
});
```

## 11. 平台差异逻辑

```ts
import { getPlatform } from '@guazi-fe/cross-utils';

const platform = getPlatform(); // 'ios' | 'android' | 'harmony' | 'h5'

// 运行时平台判断
if (TARO_ENV === 'rn') {
  // RN 专属
}

// 版本判断
import { isVersionNotBeforeThan } from '@guazi-fe/cross-utils';
if (isVersionNotBeforeThan('11.12.0', null)) {
  // 11.12.0 及以上版本
}
```

## 12. 注释规范

```ts
// 单行注释：简短说明"做什么"或"为什么"
const clueId = params?.clueId // 从路由参数获取车源id

/**
 * JSDoc：公共函数/复杂逻辑
 * @param clueId 车源id
 */
const fetchDetail = async (clueId: string) => { ... }

// console.log 调试日志格式（保留有价值的，删除无意义的）
console.log('🚀 ~ functionName ~ variable:', variable)
console.error('🚀 ~ functionName ~ error:', error)
```
