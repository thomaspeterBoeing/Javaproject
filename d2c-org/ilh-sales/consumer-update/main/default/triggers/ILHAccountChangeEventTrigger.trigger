/**
 * Copyright: TruStage
 * Purpose: Trigger for Account change event
 */
trigger ILHAccountChangeEventTrigger on AccountChangeEvent (after insert) {
	ILHPersonAccountChangeEventHelper.accountUpdate(Trigger.new);
}