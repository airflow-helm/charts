[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Configure Pod Affinity/Selectors/Tolerations

If your environment needs to use Pod [affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity), 
[nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector), 
or [tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/), 
we provide many values that allow fine-grained control over the Pod definitions.

## Global Configs

To set affinity, nodeSelector, and tolerations for all airflow Pods, you may use the `airflow.{defaultNodeSelector,defaultAffinity,defaultTolerations}` values:

```yaml
airflow:
  ## https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector
  defaultNodeSelector: {}
    # my_node_label_1: value1
    # my_node_label_2: value2

  ## https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#affinity-v1-core
  defaultAffinity: {}
    # podAffinity:
    #   requiredDuringSchedulingIgnoredDuringExecution:
    #     - labelSelector:
    #         matchExpressions:
    #           - key: security
    #             operator: In
    #             values:
    #               - S1
    #       topologyKey: topology.kubernetes.io/zone
    # podAntiAffinity:
    #   preferredDuringSchedulingIgnoredDuringExecution:
    #     - weight: 100
    #       podAffinityTerm:
    #         labelSelector:
    #           matchExpressions:
    #             - key: security
    #               operator: In
    #               values:
    #                 - S2
    #         topologyKey: topology.kubernetes.io/zone

  ## https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#toleration-v1-core
  defaultTolerations: []
    # - key: "key1"
    #   operator: "Exists"
    #   effect: "NoSchedule"
    # - key: "key2"
    #   operator: "Exists"
    #   effect: "NoSchedule"

## if using the embedded postgres chart, you will also need to define these
postgresql:
  master:
    nodeSelector: {}
    affinity: {}
    tolerations: []

## if using the embedded redis chart, you will also need to define these
redis:
  master:
    nodeSelector: {}
    affinity: {}
    tolerations: []
```

## Per-Resource Configs

To set affinity, nodeSelector, and tolerations for specific pods, you may use the following values:

```yaml
airflow:
  ## airflow KubernetesExecutor pod_template
  kubernetesPodTemplate:
    nodeSelector: {}
    affinity: {}
    tolerations: []

  ## sync deployments
  sync:
    nodeSelector: {}
    affinity: {}
    tolerations: []

## airflow schedulers
scheduler:
  nodeSelector: {}
  affinity: {}
  tolerations: []

## airflow webserver
web:
  nodeSelector: {}
  affinity: {}
  tolerations: []

## airflow workers
workers:
  nodeSelector: {}
  affinity: {}
  tolerations: []

## airflow triggerer
triggerer:
  nodeSelector: {}
  affinity: {}
  tolerations: []

## airflow workers
flower:
  nodeSelector: {}
  affinity: {}
  tolerations: []
```

> 🟦 __Tip__ 🟦
>
> The `airflow.{defaultNodeSelector,defaultAffinity,defaultTolerations}` values are overridden by the per-resource values like `scheduler.{nodeSelector,affinity,tolerations}`.
