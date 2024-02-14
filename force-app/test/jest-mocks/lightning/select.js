import { LightningElement, api } from "lwc";

export default class Select extends LightningElement {
  @api variant;
  @api name;
  @api value;
  @api options;
}
