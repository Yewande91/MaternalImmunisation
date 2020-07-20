-- --------------------------------------------------------------------------------
-- Project: Applied Research Collaborations (ARC)
-- Team   : Information and Intelligence (II)
-- Author : Vesso A. Novov
-- Date   : 10 July 2020
--
-- The file extracts summary statistics from the Pregnancy Registry data set.
-- --------------------------------------------------------------------------------
USE [NWL_WSIC_DeIdent_Sandbox]


--
-- Total number of women in the cohort.
--
DECLARE @total_num_women_in_cohort DECIMAL
SET @total_num_women_in_cohort = ( SELECT COUNT( PatientKey )
                                   FROM   NHSTrustICL.vn_arcii_pregnancy_registry_patient_index )


--
-- Total number of women with at least one GP record processed.
-- The women in this group are a subset of all women in the cohort.
--
DECLARE @total_num_women_with_preg_gpevents DECIMAL
SET @total_num_women_with_preg_gpevents = ( SELECT COUNT(*)
                                            FROM   NHSTrustICL.vn_arcii_pregnancy_registry_patient_index pin
											WHERE  pin.PatientKey IN ( SELECT DISTINCT gpe.PatientKey
											                           FROM   NHSTrustICL.vn_arcii_pregnancy_registry_gp_events gpe )
						                  )

--
-- Total number of women with at least one pregnancy in the Pregnancy Register.
-- The women in this group are a subset of all women in the cohort.
--
DECLARE @total_num_women_in_preg_registry DECIMAL
SET @total_num_women_in_preg_registry = ( SELECT COUNT( DISTINCT mother_wsic_id )
                                          FROM   NHSTrustICL.vn_arcii_pregnancy_registry )


--
-- Total number of women with at least one pregnancy at an age outside the range of interest.
-- The women in this group are a subset of all women in the cohort.
-- They also might have pregnancies in the Pregnancy Registry - i.e. pregnancies at an age within
-- the range of interest.
--
DECLARE @total_num_women_with_pregnancy_our_of_age_range DECIMAL
SET @total_num_women_with_pregnancy_our_of_age_range = ( SELECT COUNT( DISTINCT mother_wsic_id )
                                                         FROM   NHSTrustICL.vn_arcii_pregnancy_registry_out_of_age_range )

--
-- Total number of GP records processed.
-- The records belong to the women in the cohort AND have a ReadCodeV2 from 
-- one of our 3611 pregnnacy-related codes (a subset of the Minassian's 4200).
--
DECLARE @total_num_preg_gpevents DECIMAL
SET @total_num_preg_gpevents = ( SELECT COUNT(*)
                                 FROM   NHSTrustICL.vn_arcii_pregnancy_registry_gp_events )


--
-- Total number of pregnancies in the Pregnancy Register.
-- The total does not include pregnancy episodes of women whose age was
-- outside the range of interest.
--
DECLARE @total_num_pregnancies DECIMAL
SET @total_num_pregnancies = ( SELECT COUNT(*) 
                               FROM   NHSTrustICL.vn_arcii_pregnancy_registry )


--
-- Total number of pregnancies Not in the Pregnancy Registry.
-- The total includes only pregnancy episodes of women whose age was
-- outside the range of interest.
--
DECLARE @total_num_pregnancies_out_of_age_range DECIMAL
SET @total_num_pregnancies_out_of_age_range = ( SELECT COUNT(*) 
                                                FROM   NHSTrustICL.vn_arcii_pregnancy_registry_out_of_age_range )


--
-- Display the totals extracted above.
--
SELECT FORMAT( @total_num_pregnancies, 'N0' )                  AS 'Pregnancies in Pregnancy Registry',
	   FORMAT( @total_num_pregnancies_out_of_age_range, 'N0' ) AS 'Pregnancies not in Pregnancy Registry'


SELECT FORMAT( @total_num_women_in_cohort, 'N0' )            AS 'Women in cohort',
       FORMAT( (@total_num_women_in_cohort 
	            - 
			    @total_num_women_with_preg_gpevents), 'N0' ) AS 'Women with no preg-related GP events',
       FORMAT( @total_num_women_with_preg_gpevents, 'N0' )   AS 'Women with preg-related GP events',
	   
	   FORMAT( @total_num_women_in_preg_registry, 'N0' )     AS 'Women with preg-related GP events, who are in Pregnancy Registry',
	   FORMAT( (@total_num_women_with_preg_gpevents 
	            - 
			    @total_num_women_in_preg_registry), 'N0' )   AS 'Women with preg-related GP events, who are not in Pregnancy Registry'
	   
	   
SELECT FORMAT( @total_num_preg_gpevents, 'N0' ) AS 'Pregnancy-related GP events'


SELECT FORMAT( @total_num_women_with_pregnancy_our_of_age_range, 'N0' ) AS 'Women with preg-related GP events, with at least one pregnancy at age outside range of interest'


--
-- Total number of women with GP events but not in Pregnancy Registry
-- and the total number of their GP event records.
-- The number does not include women whose age at pregnancy start is outside the age range of interest.
--
SELECT   FORMAT( COUNT( DISTINCT gpe.PatientKey ), 'N0' )           AS 'Women with preg-related GP events, with no pregnancies',
         FORMAT( ( SUM ( CAST( matrix.edd AS INT ) ) +
                   SUM ( CAST( matrix.edc AS INT ) ) +
		           SUM ( CAST( matrix.lmp AS INT ) ) +
		           SUM ( CAST( matrix.postnatal_8wk AS INT ) ) +
		           SUM ( CAST( matrix.postnatal_other AS INT ) ) +  
		           SUM ( CAST( matrix.preg_related AS INT ) )
		 ), 'N0' )                                                  AS '... their GP event records not associated with, or not used for indicating a pregnancy episode',
		 FORMAT( ( -- the following totals should be zero, otherwise ( at least some of ) these women should be in the Pregnancy Registry
		           SUM ( CAST( matrix.delivery AS INT ) ) +
                   SUM ( CAST( matrix.antenatal AS INT ) ) +
		           SUM ( CAST( matrix.blighted_ovum AS INT ) ) +
		           SUM ( CAST( matrix.ectopic AS INT ) ) +
		           SUM ( CAST( matrix.loss_unspecified AS INT ) ) +
		           SUM ( CAST( matrix.miscarriage AS INT ) ) +
		           SUM ( CAST( matrix.molar AS INT ) ) +
		           SUM ( CAST( matrix.tofp AS INT ) ) +
		           SUM ( CAST( matrix.top_probable AS INT ) ) 
		 ), 'N0' )                                                  AS '... their GP event records associated with, or used for indicating a pregnancy episode ( should be zero )'
FROM     NHSTrustICL.vn_arcii_pregnancy_registry_gp_events gpe
JOIN     NHSTrustICL.vn_CTV2_CPRD_PREGN_matrix             matrix
ON       gpe.ReadCodeV2 COLLATE sql_latin1_general_cp1_cs_as = matrix.code
WHERE    gpe.PatientKey NOT IN ( SELECT DISTINCT pr.mother_wsic_id
                                 FROM   NHSTrustICL.vn_arcii_pregnancy_registry pr
                               )
         AND
         gpe.PatientKey NOT IN ( SELECT DISTINCT pro.mother_wsic_id
								 FROM   NHSTrustICL.vn_arcii_pregnancy_registry_out_of_age_range pro ) 


--
-- Total number of women with GP event records and with at least one pregnancy in Pregnancy Registry
-- and their total number of GP event records.
-- The number includes women whose age at pregnancy start is outside the age range of interest.
--
SELECT   FORMAT( COUNT( DISTINCT gpe.PatientKey ), 'N0' )           AS 'Women with preg-related GP events, with at least one pregnancy in Pregnancy Registry',
         FORMAT( ( SUM ( CAST( matrix.edd AS INT ) ) +
                   SUM ( CAST( matrix.edc AS INT ) ) +
		           SUM ( CAST( matrix.lmp AS INT ) ) +
		           SUM ( CAST( matrix.delivery AS INT ) ) +
                   SUM ( CAST( matrix.antenatal AS INT ) ) +
		           SUM ( CAST( matrix.postnatal_8wk AS INT ) ) +
		           SUM ( CAST( matrix.blighted_ovum AS INT ) ) +
		           SUM ( CAST( matrix.ectopic AS INT ) ) +
		           SUM ( CAST( matrix.loss_unspecified AS INT ) ) +
		           SUM ( CAST( matrix.miscarriage AS INT ) ) +
		           SUM ( CAST( matrix.molar AS INT ) ) +
		           SUM ( CAST( matrix.tofp AS INT ) ) +
		           SUM ( CAST( matrix.top_probable AS INT ) ) +
		           SUM ( CAST( matrix.postnatal_other AS INT ) ) +
		           SUM ( CAST( matrix.preg_related AS INT ) )
		 ), 'N0' )                                                  AS '... their GP event records associated with, or used for indicating a pregnancy episode'
FROM     NHSTrustICL.vn_arcii_pregnancy_registry_gp_events gpe
JOIN     NHSTrustICL.vn_CTV2_CPRD_PREGN_matrix             matrix
ON       gpe.ReadCodeV2 COLLATE sql_latin1_general_cp1_cs_as = matrix.code
WHERE    gpe.PatientKey IN ( SELECT DISTINCT pr.mother_wsic_id
                             FROM   NHSTrustICL.vn_arcii_pregnancy_registry pr )



--
-- Display the distribution of the various number-of-pregnancy-per-woman, and their frequency within the
-- total number of women with at least one pregnancy in the Pregnancy Registry.
-- These numbers do not include women whose age at pregnancy start was outside the age range of interest.
--
;WITH cte ( mother_wsic_id,
            N_pregnancies_per_woman
          )
  AS
  ( SELECT   mother_wsic_id,
             total_pregnancies
    FROM     NHSTrustICL.vn_arcii_pregnancy_registry
	GROUP BY mother_wsic_id,
             total_pregnancies
  )

  SELECT   N_pregnancies_per_woman                                               AS 'N Pregnancies/Woman (P/W)',
           FORMAT( COUNT(*), 'N0' )                                              AS 'Total N(P/W)',
		   FORMAT( ((COUNT(*) / @total_num_women_in_preg_registry) * 100), 'N' ) AS 'N(P/W) / all Women in Pregnancy Registry (%)'
  FROM     cte
  GROUP BY ROLLUP( N_pregnancies_per_woman )



--
-- Display the distribution of the various number-of-pregnancy-per-woman, and their frequency within the
-- total number of pregnancies in the Pregnancy Registry.
-- These numbers do not include pregnancies of women whose age was outside the age range of interest.
--
SELECT   total_pregnancies                                          AS 'N Pregnancies/Woman (P/W)',
         FORMAT( COUNT(*), 'N0' )                                   AS 'Total N(P/W)',
		 FORMAT( ((COUNT(*) / @total_num_pregnancies) * 100), 'N' ) AS 'N(P/W) / all Pregnancies in Pregnancy Registry (%)'
FROM     NHSTrustICL.vn_arcii_pregnancy_registry 
GROUP BY ROLLUP( total_pregnancies )



--
-- Display the distribution of the various type-of-pregnancy, and their frequency within the
-- total number of pregnancies in the Pregnancy Registry and total number of women with at least one
-- pregnancy in the Pregnancy Registry.
-- These numbers do not include women whose age at pregnancy start was outside the age range of interest.
--
SELECT   ( CASE
              WHEN (preg_outcome = 0)
			   THEN 'Multiple'
			 WHEN (preg_outcome = 1)
			   THEN 'Live birth ( excluding ''multiple'' and ''stillbirth'' )'
			 WHEN (preg_outcome = 2)
			   THEN 'Stillbirth'
			 WHEN (preg_outcome = 3)
			   THEN 'Multiple and stillbirth ( live + stillborn OR all stillborn )'
			 WHEN (preg_outcome = 4)
			   THEN 'Miscarriage'
			 WHEN (preg_outcome = 5)
			   THEN 'Termination (TOP)'
			 WHEN (preg_outcome = 6)
			   THEN 'Probable TOP'
			 WHEN (preg_outcome = 7)
			   THEN 'Ectopic pregnancy'
			 WHEN (preg_outcome = 8)
			   THEN 'Molar pregnancy'
			 WHEN (preg_outcome = 9)
			   THEN 'Blighted ovum'
			 WHEN (preg_outcome = 10)
			   THEN 'Unspecified loss'
			 WHEN (preg_outcome = 11)
			   THEN 'Delivery based on a third trimester pregnancy record'
			 WHEN (preg_outcome = 12)
			   THEN 'Delivery based on a late pregnancy record'
			 WHEN (preg_outcome = 13)
			   THEN 'Outcome uknown'
			WHEN (GROUPING( preg_outcome ) = 1)
			   THEN '  TOTAL'
		   END 
         )                                                              AS 'Pregnancy Outcome Type (POT)',
         FORMAT( COUNT(*), 'N0' )                                       AS 'Total (POT)',
         FORMAT( ((COUNT(*) / @total_num_pregnancies) * 100), 'N' )     AS '(POT) / all Pregnancies in Pregnancy Registry (%)',
		 FORMAT( (COUNT(*) / @total_num_women_in_preg_registry), 'N2' ) AS '(POT) / all Women in Pregnancy Registry (n)'
FROM     NHSTrustICL.vn_arcii_pregnancy_registry 
GROUP BY ROLLUP( preg_outcome )
