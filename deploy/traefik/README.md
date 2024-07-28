# 如何更新依赖？

`Chart.yaml` 文件中的 `dependencies` 字段指定了依赖的 Helm Chart，`requirements.yaml` 文件中的 `dependencies` 字段指定了依赖的 Helm Chart 的版本。

在[这里](https://github.com/traefik/traefik-helm-chart/blob/master/traefik/Chart.yaml) 查看最新版本。

执行：

```
helm dependency update ./deploy/traefik
```
