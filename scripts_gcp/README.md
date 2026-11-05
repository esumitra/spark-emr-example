###

Log into https://console.cloud.google.com/
Download google cloud for your OS: https://docs.cloud.google.com/sdk/docs/install-sdk

You should be able to run `gcloud init`
On Windows, if you have issues with python, install it directly from python.org, not the bundled one.

Create a bucket, choosing single region for lower cost by going to https://console.cloud.google.com/storage/
You can mark it as a favorite by clicking on the 3-bar navigation menu in the top left

For WSL installation, see here: https://gist.github.com/klimekszymon/b7fe9745af6e255f8c939c3c0e208f8a
However, all the links in the steps need to be changed from MD format, removing the brackets and link in parentheses.

To log in:

```
gcloud auth application-default login
#Check the boxes in browser
gcloud auth application-default print-access-token
```

You will also need to enable DataFlow by going to https://console.developers.google.com/apis/api/dataflow.googleapis.com/overview
which shows up as PERMISSION_DENIED the first time.

Copying files:

```
gcloud storage cp yourfile gs://yourbucket/yourfolder

```
