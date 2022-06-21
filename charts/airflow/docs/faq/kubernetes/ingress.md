[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Configure Kubernetes Ingress

The chart provides the `ingress.*` values for deploying a Kubernetes Ingress to allow access to airflow outside the cluster.

Consider the situation where you already have something hosted at the root of your domain, you might want to place airflow under a URL-prefix:
- http://example.com/airflow/
- http://example.com/airflow/flower

For example, assuming you have an Ingress Controller with an IngressClass named "nginx" deployed:

```yaml
airflow:
  config: 
    AIRFLOW__WEBSERVER__BASE_URL: "http://example.com/airflow/"
    AIRFLOW__CELERY__FLOWER_URL_PREFIX: "/airflow/flower"

ingress:
  enabled: true
  
  ## WARNING: set as "networking.k8s.io/v1beta1" for Kubernetes 1.18 and earlier
  apiVersion: networking.k8s.io/v1
  
  ## airflow webserver ingress configs
  web:
    annotations: {}
    host: "example.com"
    path: "/airflow"
    ## WARNING: requires Kubernetes 1.18 or later, use "kubernetes.io/ingress.class" annotation for older versions
    ingressClassName: "nginx"
    
  ## flower ingress configs
  flower:
    annotations: {}
    host: "example.com"
    path: "/airflow/flower"
    ## WARNING: requires Kubernetes 1.18 or later, use "kubernetes.io/ingress.class" annotation for older versions
    ingressClassName: "nginx"
```

## Preceding and Succeeding Paths

We expose the `ingress.web.precedingPaths` and `ingress.web.succeedingPaths` values, which are __before__ and __after__ the default path respectively.

> 🟦 __Tip__ 🟦
>
> A common use-case is [enabling SSL with the aws-alb-ingress-controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/tasks/ssl_redirect/), 
> which needs a redirect path to be hit before the airflow-webserver one.

For example, setting `ingress.web.precedingPaths` for an aws-alb-ingress-controller with SSL:

```yaml
ingress:
  web:
    precedingPaths:
      - path: "/*"
        serviceName: "ssl-redirect"
        servicePort: "use-annotation"
```