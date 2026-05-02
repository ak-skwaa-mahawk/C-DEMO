#ifndef VAULT_CLIENT_H
#define VAULT_CLIENT_H

#ifdef __cplusplus
extern "C" {
#endif

// Store a state blob (JSON string) under a purpose
int vault_store_state(const char *json_blob, const char *purpose);

// Request a derived metric (Vault never returns raw data)
int vault_compute_metric(const char *metric_name, char *out_buf, int buf_size);

#ifdef __cplusplus
}
#endif

#endif