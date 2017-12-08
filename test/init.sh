
### Copy/paste next line in init-sms-free.sh and replace [login|passwd] :
### soaf_create_net_account "test.sms.free.account" "[login]" "[passwd]"
TEST_INIT_SMS_FREE_FILE=$TEST_HOME/init-sms-free.sh
if [ -f $TEST_INIT_SMS_FREE_FILE ]
then
	. $TEST_INIT_SMS_FREE_FILE
	soaf_create_notif_sms_free_nature "test.notif.sms.free" \
		"test.sms.free.account"
fi
