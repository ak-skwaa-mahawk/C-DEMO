#include "vault_client.h"
#include <stdio.h>
#include <string.h>
#include <curl/curl.h>

int vault_store_state(const char *json_blob, const char *purpose) {
    CURL *curl = curl_easy_init();
    if (!curl) return -1;

    char url[256];
    snprintf(url, sizeof(url), "http://127.0.0.1:7777/store/%s", purpose);

    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_blob);

    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);

    return (res == CURLE_OK) ? 0 : -1;
}

int vault_compute_metric(const char *metric_name, char *out_buf, int buf_size) {
    CURL *curl = curl_easy_init();
    if (!curl) return -1;

    char url[256];
    snprintf(url, sizeof(url), "http://127.0.0.1:7777/metric/%s", metric_name);

    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, out_buf);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, fwrite);

    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);

    return (res == CURLE_OK) ? 0 : -1;
}