# Splunk Deployment on OpenShift

This documentation provides an overview of the configuration needed to deploy
Splunk in an OpenShift environment.

## Pre-requisite:

- [Configure NFS-Storage](https://github.com/redhat-appstudio/infra-deployments/tree/main/hack/quickcluster) 
   before using a provisioned [Quickcluster](https://resourcehub.redhat.com).

# Deployment Steps

- Apply the provided YAML configuration

    ```
    oc create -f yaml/configuration.yml
    ```

# Accessing Splunk

1. Once deployed, use `oc get route` to view the Splunk routes URL's.

    ```
    NAME         HOST/PORT                                   PATH   SERVICES   PORT
    splunk-api   splunk-api-splunk.apps.<cluster-hostname>          splunk     8089
    splunk-hec   splunk-hec-splunk.apps.<cluster-hostname>          splunk     8088
    splunk-web   splunk-web-splunk.apps.<cluster-hostname>          splunk     8000
    ```

2. Access the Splunk-WEB UI by using the `splunk-web` route URL in `Step 1` from browser with
   default user and password `(u: admin, p: Password)`
   
    ```
    http://splunk-web-splunk.apps.<cluster-hostname>
    ```

3. Access the Splunk-API by using the `splunk-api` route URL from `step 1` in terminal

    ```
    curl -k -u admin:Password http://splunk-api-splunk.apps.<cluster-hostname>/services/server/info`
    ```

4. Triggerring an event with Splunk-HEC Endpoint from terminal
   You need an authorization token to send data to Splunk via HEC endpoints.

    ```
    hec-token-dev-app  : 71a657fe-ea4c-4994-adc8-2032d95c9861
    hec-token-dev-audit: 5ab43f3f-0eae-4066-9151-d5d2cbfd3a5a
    ```
   Once you choose which index to send a log to, use the appropriate hec-token
   with below curl cmd:

    ```
    curl -H "Authorization: Splunk <hec-token>" http://splunk-hec-splunk.apps.<cluster-hostname>/services/collector/event -d '{"sourcetype": "my_sample_data", "event": "http auth ftw!!!!"}'
    ```

## Cleanup
To remove the configurations:

```
oc delete route splunk-web splunk-api splunk-hec && oc delete dc,svc splunk && oc delete pvc splunk-db-pvc; oc delete sa splunk-sa; oc delete project splunk
```
