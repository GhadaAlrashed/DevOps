# Phase 3: My Experience Setting up Grafana Loki and Vector

## Setting up Grafana Loki

1. **Adding the Grafana Helm repository**:

   I added the Grafana Helm repository and updated it using the following commands:

   ```bash
   helm repo add grafana https://grafana.github.io/helm-charts
   helm repo update
    ```
2. Installing or upgrading Loki using Helm:

    I installed or upgraded Loki using the command below:

    ```bash
    helm upgrade --install loki grafana/loki-stack --namespace logging --create-namespace
    ```

3. Checking the status of resources in the logging namespace:

    To verify the status of all resources in the logging namespace, I ran the following command:

    ```bash
    kubectl get all -n logging
    ```
    After installing Loki, I created a new namespace named test and added deployment.yaml to it. I then applied it with the following commands:
    ```bash
    kubectl create ns test
    kubectl apply -f pod.yaml -n test
    ```

4. Checking logs for promtail:

    To check the logs for promtail, I used the following command:

    ```bash
    kubectl logs -n logging -l app.kubernetes.io/name=promtail
    ```

    The output looked like this:

    ```bash
    msg="watching new directory" directory=/var/log/pods/test_hello-logger_...
    ```

5. Using port-forwarding to access the Loki UI:

    I performed port-forwarding to access the Loki UI on port 3100:

    ```bash
    kubectl port-forward -n logging svc/loki 3100:3100
    ```


6. Querying data using the API:

    Querying for labels:

    I used the following prefix to query the available labels in Loki:

    ```bash
    /proxy/3100/loki/api/v1/labels
    ```
    The response looked like this:

    ```json
    {
    "status": "success",
    "data": [
        "app",
        "component",
        "container",
        "filename",
        "instance",
        "job",
        "namespace",
        "node_name",
        "pod",
        "stream"
    ]
    }
    ```

    Querying logs for a specific namespace:

    I used the following prefix to query logs from the test namespace:

    ```bash
    /proxy/3100/loki/api/v1/query_range?query={namespace="test"}
     ```
    This allowed me to view logs from any namespace using this prefix.


# Deploying Vector instead of Loki Promtail.

In case I wanted to use Vector instead of Loki Promtail, I followed these steps:

## 1. Deleting the Loki Promtail DaemonSet:

I deleted the DaemonSet for Loki Promtail:


    kubectl delete daemonset loki-promtail -n logging


## 2. Installing Vector using Helm:

I installed Vector in the logging namespace using Helm with the values.yaml configuration file:

    
    helm install vector vector/vector -n logging -f values.yaml --create-namespace

I made sure that the values.yaml file was in the same folder.

# Final Outcome
At this point, I successfully installed and configured both Loki and Vector. I can now use Loki to monitor logs in the logging namespace and use Vector as a replacement for Loki Promtail to achieve the same functionality.