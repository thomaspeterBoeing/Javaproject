%dw 2.0
import * from dw::util::Coercions
import * from dw::core::Dates
input payload application/json
output application/apex
---
payload map(x)-> {
    sourceId: toString(x.SequenceNumber default ''),
    offerDescription: x.Offer[0].OfferCodeDescription default '',
    campaignProduct: x.InitiatingProduct.OfsProductCode default '',
    channelCode: x.ContactType default '',
    contractNumber: x.Organization.ContractNumber default '',
    mailingDate: x.ContactDate as Date default null
} as Object {class: "ILHMarketingHistoryResultsWrapper"}