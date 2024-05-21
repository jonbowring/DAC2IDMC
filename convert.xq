xquery version "3.0";

import module namespace jb = 'http://informatica.com' at 'functions.xq';
declare option saxon:output "omit-xml-declaration=yes";
declare variable $tname as xs:string external;
declare variable $tflowid as xs:string external;

let $plans := doc('in/plans.xml')
let $params := doc('in/params.xml')
let $steps := $plans//Q{}row
let $order := for $item in distinct-values($steps//Q{}plan_step_order)
                order by $item
                return $item

let $tflow := <aetgt:getResponse xmlns:aetgt="http://schemas.active-endpoints.com/appmodules/repository/2010/10/avrepository.xsd"
                   xmlns:types1="http://schemas.active-endpoints.com/appmodules/repository/2010/10/avrepository.xsd">
   <types1:Item>
      <types1:EntryId>3RKWa-gt-522578-2023-12-01T22:58:53.881Z::tf.xml</types1:EntryId>
      <types1:Name>{ $tname }</types1:Name>
      <types1:MimeType>application/xml+taskflow</types1:MimeType>
      <types1:Description/>
      <types1:AppliesTo/>
      <types1:Tags/>
      <types1:VersionLabel>1.0</types1:VersionLabel>
      <types1:State>CURRENT</types1:State>
      <types1:ProcessGroup/>
      <types1:CreatedBy>jbowring_APJS_tspod_SO</types1:CreatedBy>
      <types1:CreationDate>2023-12-01T22:58:54Z</types1:CreationDate>
      <types1:ModifiedBy/>
      <types1:PublicationStatus>unpublished</types1:PublicationStatus>
      <types1:AutosaveExists>false</types1:AutosaveExists>
      <types1:Entry>
         <taskflow xmlns="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd"
                   xmlns:tfm="http://schemas.active-endpoints.com/appmodules/screenflow/2021/04/taskflowModel.xsd"
                   xmlns:list="urn:activevos:spi:list:functions"
                   displayName="{ $tname }"
                   name="{ $tname }"
                   overrideAPIName="false">
            <parameterSet xmlns="http://schemas.active-endpoints.com/appmodules/screenflow/2021/04/taskflowModel.xsd"/>
            <appliesTo/>
            <description/>
            <tags/>
            <generator>Informatica Process Designer 11</generator>
            
            <tempFields>
               {
                  for $step in $steps[Q{}plan_step_type = 'REGULAR']
                    return <field description="" name="{data($step/Q{}step_name)}" type="reference">
                      <options>
                        <option name="failOnNotRun">false</option>
                        <option name="failOnFault">false</option>
                        <option name="referenceTo">$po:{replace($step/Q{}step_name, '[^A-Za-z0-9\-]+', '-')}</option>
                      </options>
                  </field>
                }
                {
                  for $step in $steps[Q{}plan_step_type = 'CREATE_QUERY_INDEXES']
                    return <field description="" name="{data($step/Q{}step_name)}" type="reference">
                      <options>
                        <option name="failOnNotRun">false</option>
                        <option name="failOnFault">false</option>
                        <option name="referenceTo">$po:INFA-commandTask</option>
                      </options>
                  </field>
                }
            </tempFields>
            <notes/>
            <deployment skipIfRunning="false" suspendOnFault="false" tracingLevel="verbose">
               <rest/>
            </deployment>
            <flow id="a">
               <start id="start">
                  <link id="startLink" targetId="step{$order[1]}"/>
               </start>
                {
                  for $seq at $i in $order
                    let $next := jb:getNextStep($i, $order)
                    let $seqCount := count($steps[Q{}plan_step_order = $seq])
                    let $tasks := $steps[Q{}plan_step_order = $seq]
                    let $taskID := $steps[Q{}plan_step_order = $seq]/Q{}infa_id/text()
                    let $container := if($seqCount = 1) then (
                          jb:addContainer($seq, $next, $tasks[1], $params)
                    ) else (
                          jb:addParallels($seq, $next, $tasks, $params)
                    )
                    return $container
                }
               <end id="end"/>
            </flow>
            <dependencies>
               {
                  for $step in $steps
                     let $dependency := jb:addDependency($step)
                     return $dependency
               } 
            </dependencies>
         </taskflow>
      </types1:Entry>
      <types1:GUID>{ $tflowid }</types1:GUID>
      <types1:DisplayName>{ $tname }</types1:DisplayName>
   </types1:Item>
   <types1:CurrentServerDateTime>2023-12-01T22:59:59.17Z</types1:CurrentServerDateTime>
</aetgt:getResponse>



return $tflow