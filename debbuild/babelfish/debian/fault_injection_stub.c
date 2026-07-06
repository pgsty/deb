#include "postgres.h"
#include "src/include/faultinjection.h"

static void
noop_fault(void *arg, int *num_occurrences)
{
	(void) arg;
	if (num_occurrences != NULL && *num_occurrences > 0)
		(*num_occurrences)--;
}

TEST_TYPE_LIST =
{
	{ TestType, "Test", NIL },
	{ ParseHeaderType, "TDS request header", NIL },
	{ PreParsingType, "TDS pre-parsing", NIL },
	{ ParseRpcType, "TDS RPC Parsing", NIL },
	{ PostParsingType, "TDS post-parsing", NIL },
	{ InvalidType, "", NIL }
};

TEST_LIST =
{
	{ "noop_fault", TestType, 0, &noop_fault },
	{ "", InvalidType, 0, NULL }
};
