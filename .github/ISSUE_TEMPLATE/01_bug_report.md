---
name: Bug Report
about: Report something not working properly!
title: ''
labels: 'bug' 
assignees: ''
---

<!-- ⚠️ BEFORE you submit an issue, please check if a similar issue already exists -->

## What is the bug?

The bug is...


## What version of the chart?

I am using version `X.X.X` of this chart.


## What version of Kubernetes?

```console

# output of `kubectl version` command
Client Version: ...
Server Version: ...

```


## What version of Helm?

```console

# output of `helm version` command
version.BuildInfo{....

```


## Any non-default Helm values?

<details>
<summary>click to expand</summary>

```yaml
## PASTE BELOW THIS LINE
## --------------------------------------------------

## non-default helm values (in YAML format)
airflow: 
  ...
workers: 
  ...
  
## --------------------------------------------------
## PASTE ABOVE THIS LINE
```

</details>