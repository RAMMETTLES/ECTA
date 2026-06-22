library Panniculectomy version '1.0.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers


//include otherLibrary version 'x.x' called otherLibrary
//codesystem codeSystemName : 'OID' version 'x.x'
//valueset valuesetName : 'OID' version 'x.x' codesystems{codeSystem1 , codeSystem2, etc}
//code codeName : 'OID' from codeSystemName display 'displayName'
//concept conceptName : {codeName1, codeName2, etc} display 'displayName'
//parameter parameterName (dataType or default value)

codesystem "ICD-10-CM": 'http://hl7.org/fhir/sid/icd-10-cm'
codesystem "LOINC": 'http://loinc.org'
codesystem "HCPCS": 'https://hcpcs.codes/'
codesystem "SNOMED-CT": 'http://snomed.info/sct'
codesystem "CPT": 'https://www.aapc.com/resources/medical-coding/cpt.aspx'

valueset "Panniculectomy": '2.16.840.1.113883.3.6037.1001.23.99.80'
valueset "Panniculectomy related diagnoses": '2.16.840.1.113883.3.6037.1001.23.99.84'
valueset "Panniculectomy related secondary diagnoses": '2.16.840.1.113883.3.6037.1001.23.99.81'
valueset "Pannus Conditions": '2.16.840.1.113883.3.6037.1001.23.99.82'
valueset "Difficulty Walking Conditions": 'difficulty-walking-panniculectonomy'
valueset "Tissue breakdown severity": 'tissue-breakdown-severity-panniculectonomy'
valueset "Tissue breakdown location": 'tissue-breakdown-location-panniculectonomy'
valueset "Chronic pain character": 'chronic-pain-character-panniculectonomy'
valueset "Chronic pain location": 'chronic-pain-location-panniculectonomy'

context Patient

define PanniculectomyRequest:
  Last([ServiceRequest] ServiceReq where "ToCode"(First(ServiceReq.code.coding)) in "Panniculectomy")

define "ServiceRequestCode":
    FHIRHelpers.ToCode(First("PanniculectomyRequest".code.coding))

define "PrimaryServiceRequestCode":
	if ("ServiceRequestCode".code = '15830') then '15830' else 'other'

define "AddOnServiceRequestCode":
	if ("ServiceRequestCode".code != '15830') then "ServiceRequestCode".code else null

define ServiceEncounter:
	First([Encounter]E where 'Encounter/' + E.id.value = "PanniculectomyRequest".encounter.reference.value)
	
define "OrderDate":
    "PanniculectomyRequest".authoredOn

define "RequestedDate": 
	ToDate(start of "Normalize Interval"("PanniculectomyRequest".occurrence))

define "PanniculectomyPrimaryCondition":
	if(First([Condition]S
		where exists(S.code.coding C where C in "Panniculectomy related diagnoses")
		  and First(S.clinicalStatus.coding).code.value = 'active'
			  and First(S.verificationStatus.coding).code.value = 'confirmed') is not null)
			  then First(First([Condition]S
				where exists(S.code.coding C where C in "Panniculectomy related diagnoses")
				and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed').code.coding).code 
	else 'other'

define "PanniculectomySecondaryCondition":
	if (PanniculectomyPrimaryCondition = 'L98.7' or PanniculectomyPrimaryCondition = 'M79.3') then 
		if(First([Condition]S
			where exists(S.code.coding C where C in "Panniculectomy related secondary diagnoses")
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null)
				then First(First([Condition]S
					where exists(S.code.coding C where C in "Panniculectomy related secondary diagnoses")
					and First(S.clinicalStatus.coding).code.value = 'active'
					and First(S.verificationStatus.coding).code.value = 'confirmed').code.coding).code 
		else 'other'
	else ''

define "PannusConditionPresence":
	if(First([Condition]S
		where exists(S.code.coding C where C in "Pannus Conditions")
		and First(S.clinicalStatus.coding).code.value = 'active'
			and First(S.verificationStatus.coding).code.value = 'confirmed') is not null)
			then 'yes' 
	else 'no'

define "DifficultyWalkingPresence":
	if(First([Condition]S
		where exists(S.code.coding C where C in "Difficulty Walking Conditions")
		and First(S.clinicalStatus.coding).code.value = 'active'
			and First(S.verificationStatus.coding).code.value = 'confirmed') is not null)
			then 'yes' 
	else 'no'

define "ChronicPainObservation":
	First([Observation]O
		where exists(O.code.coding C where C in "Chronic pain character") and 
		exists(O.bodySite.coding C where C in "Chronic pain location"))


define "ChronicPainLocation":
	ToCode(First(ChronicPainObservation.bodySite.coding)).code

define "ChronicPainCharacter":
	ToCode(First(ChronicPainObservation.code.coding)).code

define "TissueBreakdownCondition":
	First([Condition]S
		where exists(S.code.coding C where C in "Tissue breakdown severity")
		and exists(S.bodySite b where exists(b.coding C where C in "Tissue breakdown location"))
		and First(S.clinicalStatus.coding).code.value = 'active'
			and First(S.verificationStatus.coding).code.value = 'confirmed')

define "TissueBreakdownLocation":
	ToCode(First(First(TissueBreakdownCondition.bodySite).coding)).code

define "TissueBreakdownSeverity":
	ToCode(First(TissueBreakdownCondition.code.coding)).code

define "IsObesityPresent":
	First([Condition]S
		where ToCode(First(S.code.coding)).code = '162864005'
		and First(S.clinicalStatus.coding).code.value = 'active'
			and First(S.verificationStatus.coding).code.value = 'confirmed') is not null

define "IsWeightSteady":
	First([Condition]S
		where ToCode(First(S.code.coding)).code = '271398006'
		and First(S.clinicalStatus.coding).code.value = 'active'
			and First(S.verificationStatus.coding).code.value = 'confirmed') is not null

define "IsIntentionalWeightLoss":
	First([Condition]S
		where ToCode(First(S.code.coding)).code = '416528001'
		and First(S.clinicalStatus.coding).code.value = 'active'
			and First(S.verificationStatus.coding).code.value = 'confirmed') is not null

define "IsBariatricSurgery":
	First([Condition]S
		where ToCode(First(S.code.coding)).code = '608848006'
		and First(S.clinicalStatus.coding).code.value = 'active'
			and First(S.verificationStatus.coding).code.value = 'confirmed') is not null

define "IsInfectionOnSkin":
	First([Condition]S
		where ToCode(First(S.code.coding)).code = '19824006'
		and First(S.clinicalStatus.coding).code.value = 'active'
			and First(S.verificationStatus.coding).code.value = 'confirmed') is not null	

define "IsInflammationOnSkin":
	First([Condition]S
		where ToCode(First(S.code.coding)).code = '363168001'
		and First(S.clinicalStatus.coding).code.value = 'active'
			and First(S.verificationStatus.coding).code.value = 'confirmed') is not null	

define "SurgeryNecessary":
	{
		(if (IsObesityPresent) then '162864005' else ''),
		(if (IsWeightSteady and IsIntentionalWeightLoss) then 'stable-weight-6mo' else ''),
		(if (IsIntentionalWeightLoss and IsBariatricSurgery and IsInfectionOnSkin and IsInflammationOnSkin) then 'stable-weight-6mo' else '')
	}

define "TopicalAntifungals":
		if (First([Condition]S
			where ToCode(First(S.code.coding)).code = '373219008'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null and
				First([Condition]S
			where ToCode(First(S.code.coding)).code = '266721009'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null) then 'refractory' 
		else if (First([Condition]S
			where ToCode(First(S.code.coding)).code = '373219008'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null and
				First([Condition]S
			where ToCode(First(S.code.coding)).code = '736979001'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null) then 'recurrent' 
		else if (First([Condition]S
			where ToCode(First(S.code.coding)).code = '373219008'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null and
				First([Condition]S
			where ToCode(First(S.code.coding)).code = '62459000'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null) then 'persistent' else ''
	
define "Corticosteroids":
		if (First([Condition]S
			where ToCode(First(S.code.coding)).code = '304275008'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null and
				First([Condition]S
			where ToCode(First(S.code.coding)).code = '266721009'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null) then 'refractory' 
		else if (First([Condition]S
			where ToCode(First(S.code.coding)).code = '266721009'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null and
				First([Condition]S
			where ToCode(First(S.code.coding)).code = '255227004'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null) then 'recurrent' 
		else if (First([Condition]S
			where ToCode(First(S.code.coding)).code = '266721009'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null and
				First([Condition]S
			where ToCode(First(S.code.coding)).code = '62459000'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null) then 'persistent' else ''

define "Antibiotics":
		if (First([Condition]S
			where ToCode(First(S.code.coding)).code = '304275008'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null and
				First([Condition]S
			where ToCode(First(S.code.coding)).code = '281789004'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null) then 'refractory'
		else if (First([Condition]S
			where ToCode(First(S.code.coding)).code = '255227004'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null and
				First([Condition]S
			where ToCode(First(S.code.coding)).code = '281789004'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null) then 'recurrent'
		else if (First([Condition]S
			where ToCode(First(S.code.coding)).code = '62459000'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null and
				First([Condition]S
			where ToCode(First(S.code.coding)).code = '281789004'
			and First(S.clinicalStatus.coding).code.value = 'active'
				and First(S.verificationStatus.coding).code.value = 'confirmed') is not null) then 'persistent' else ''
 
define function "Normalize Onset"(onset Choice<FHIR.dateTime, FHIR.Age, FHIR.Period, FHIR.Range, FHIR.string>):
  if onset is FHIR.dateTime then
	  Interval[FHIRHelpers.ToDateTime(onset as FHIR.dateTime), FHIRHelpers.ToDateTime(onset as FHIR.dateTime)]
	else if onset is FHIR.Period then
	  FHIRHelpers.ToInterval(onset as FHIR.Period)
	else if onset is FHIR.string then
    Message(null as Interval<DateTime>, true, '1', 'Error', 'Cannot compute an interval from a String value')
	else if onset is FHIR.Age then
	  Interval[FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity(onset as FHIR.Age),
		  FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity(onset as FHIR.Age) + 1 year]
	else if onset is FHIR.Range then
	  Interval[FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity((onset as FHIR.Range).low),
		  FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity((onset as FHIR.Range).high) + 1 year]
	else null

define function "Normalize Interval Procedure"(choice Choice<FHIR.dateTime, FHIR.Age, FHIR.Period, FHIR.Range, FHIR.string>):
 	 if choice is FHIR.dateTime then
 		  Interval[FHIRHelpers.ToDateTime(choice as FHIR.dateTime), FHIRHelpers.ToDateTime(choice as FHIR.dateTime)]
	  else if choice is FHIR.Period then
		  FHIRHelpers.ToInterval(choice as FHIR.Period)
		else if choice is FHIR.string then
    Message(null as Interval<DateTime>, true, '1', 'Error', 'Cannot compute an interval from a String value')
	  else if choice is FHIR.Age then
	 	  Interval[FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity(choice as FHIR.Age),
 		FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity(choice as FHIR.Age) + 1 year]
		else if choice is FHIR.Range then
	  Interval[FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity((choice as FHIR.Range).low),
		  FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity((choice as FHIR.Range).high) + 1 year]
	  else null


// Helper functions needed for this scope

define function "Normalize Interval"(onset Choice<FHIR.dateTime, FHIR.Age, FHIR.Period, FHIR.Range, FHIR.string>):
  if onset is FHIR.dateTime then Interval[FHIRHelpers.ToDateTime ( onset as FHIR.dateTime ), FHIRHelpers.ToDateTime ( onset as FHIR.dateTime )]
    else if onset is FHIR.Period then FHIRHelpers.ToInterval ( onset as FHIR.Period ) 
    else if onset is FHIR.Age then Interval[FHIRHelpers.ToDate ( Patient.birthDate ) + FHIRHelpers.ToQuantity ( onset as FHIR.Age ), FHIRHelpers.ToDate ( Patient.birthDate ) + FHIRHelpers.ToQuantity ( onset as FHIR.Age ) + 1 year ] 
    else null

	
define function ToCode(coding FHIR.Coding):
    if coding is null then
        null
    else
        System.Code {
          code: coding.code.value,
          system: coding.system.value,
          version: coding.version.value,
          display: coding.display.value
        }

define function "GetId"(uri String):
	Last(Split(uri, '/'))

define function "EncounterDiagnosis"(Encounter Encounter):
	Encounter.diagnosis D
	return First([Condition]C
				where C.id.value = "GetId"(D.condition.reference.value)
					and FHIRHelpers.ToInteger(D.rank) = 2)
