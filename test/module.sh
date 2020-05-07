
test_module_deadlock() {
	soaf_create_module "m1" "1.0.0" "" "" "" "" "" "" "" "m2"
	soaf_create_module "m2" "1.0.0" "" "" "" "" "" "" "" "m3"
	soaf_create_module "m3" "1.0.0" "" "" "" "" "" "" "" "m1"
}

test_module_notfnd() {
	soaf_create_module "m1" "1.0.0"
	soaf_create_module "m2" "1.0.0"
	soaf_create_module "m3" "1.0.0" "" "" "" "" "" "" "" "m4"
}

test_module_ok() {
	soaf_create_module "m1" "1.0.0"
	soaf_create_module "m2" "1.0.0"
	soaf_create_module "m3" "1.0.0" "" "" "" "" "" "" "" "m4 m2"
	soaf_create_module "m4" "1.0.0" "" "" "" "" "" "" "" "m5"
	soaf_create_module "m5" "1.0.0"
}

case $ACTION in
module)
	case $ERR_TYPE in
		deadlock) test_module_deadlock;;
		notfnd) test_module_notfnd;;
		*) test_module_ok;;
	esac
	;;
*)
	test_module_ok
	;;
esac
