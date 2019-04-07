trigger NewChiledContact on Contact (after insert, after update,  before update, before delete) {
  /* 
  Create new custom field "Parent Contact" with Lookup type on Contact object. 
  Create new custom field "Child Contacts" with Number type on Contact object.
  Implement functionality to calculate number of child contacts for every contact. 
  I.e. if some contact has 2 child contacts and these child contacts has 2 more child contacts each then parent contact should have 6 in the "Child Contacts" field.
  The functionality should allow mass updates
 */
  new NewChiledContactTriggerHandler().run();
}