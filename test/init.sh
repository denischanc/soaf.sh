
### Define TEST_SMS_FREE_LOGIN and TEST_SMS_FREE_PASSWD in ext/init.sh
### TEST_SMS_FREE_LOGIN=[login]
### TEST_SMS_FREE_PASSWD=[passwd]
if [ -n "$TEST_SMS_FREE_LOGIN" -a -n "$TEST_SMS_FREE_PASSWD" ]
then
	soaf_create_net_account "test.sms.free.account" \
		"$TEST_SMS_FREE_LOGIN" "$TEST_SMS_FREE_PASSWD"
	soaf_create_notif_sms_free_nature "test.notif.sms.free" \
		"test.sms.free.account"
fi

### Define TEST_TO_ADDR in ext/init.sh
### TEST_TO_ADDR=[mail address]
if [ -n "$TEST_TO_ADDR" ]
then
	soaf_create_notif_mail_nature "test.notif.mail" "$TEST_TO_ADDR"
fi
