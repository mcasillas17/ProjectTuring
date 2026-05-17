package tools

type Policy string

const (
	PolicySafe             Policy = "safe"
	PolicyApprovalRequired Policy = "approval_required"
	PolicyDisabled         Policy = "disabled"
)

var policies = map[string]Policy{
	"system.time":   PolicySafe,
	"system.health": PolicySafe,
	"system.echo":   PolicySafe,
	"files.create":  PolicyApprovalRequired,
	"files.update":  PolicyApprovalRequired,
}

func GetPolicy(toolName string) (Policy, bool) {
	policy, ok := policies[toolName]
	return policy, ok
}
