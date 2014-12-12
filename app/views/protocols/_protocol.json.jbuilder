json.(protocol)

json.sparc_id protocol.sparc_id
json.status protocol.status
json.short_title protocol.short_title
json.irb_approval_date protocol.irb_approval_date
json.irb_expiration_date protocol.irb_expiration_date
json.irb_status protocol.irb_status
json.start_date protocol.start_date
json.end_date protocol.end_date
json.study_cost protocol.study_cost
json.stored_percent_subsidy protocol.stored_percent_subsidy
json.subsidy_committed number_to_currency(protocol.subsidy_committed)
json.subsidy_expended protocol.subsidy_expended