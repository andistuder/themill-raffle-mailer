# The Mill E17 Mailer

This is a script that allocates raffle tickets to a sales report.

You pass in a sales report at run time, and it returns a copy of the sales report with added columns:

- `raffle_tickets`: lists the raffle tickets allocated
- `email_status`: a control column that states mailer status. 2XX is good, 100 indicates dry run mode
- `emailed_at`: a control column that states the emailed ad time.

## Run via terminal command

```
bin/process_salesreport SALECSREPORT.csv DESTINATION.csv
```

## Prerequisites

You need a SendGrid account and have an API key issued.

## Configuration

The following environment variables can/must be set:

- `SENDGRID_API_KEY`, string, required
- `DISABLE_MAILER`, true/false, optional
