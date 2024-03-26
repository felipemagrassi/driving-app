package gateway

type MailerGateway struct{}

func NewMailerGateway() *MailerGateway {
	return &MailerGateway{}
}
