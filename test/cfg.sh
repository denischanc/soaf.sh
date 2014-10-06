
SOAF_LOG_LEVEL=$SOAF_LOG_DEBUG

soaf_create_net_account "test.sms.free.account" "" ""
soaf_create_notif_sms_free_nature "test.notif.sms.free" \
	"test.sms.free.account"
