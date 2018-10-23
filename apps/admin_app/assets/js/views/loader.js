import MainView    from './main';
import TaxonomyIndexView from './taxonomy/index';
import TaxonomyTaxonomyView from './taxonomy/taxonomy';
import Payment_methodNewView from './payment_method/new';
import ProductProduct_categoryView from './product/product_category';
import ProductEditView from './product/edit';
import OrderIndexView from './order/index';
import ZoneNewView from './zone/new';
import ProductIndexView from './product/index';
import Shipping_policyIndexView from './shipping_policy/index_edit';
import Shipping_policyEditView from './shipping_policy/index_edit';

// Collection of specific view modules
const views = {
  TaxonomyIndexView,
  TaxonomyTaxonomyView,
  Payment_methodNewView,
  ProductProduct_categoryView,
  ProductEditView,
  ProductIndexView,
  OrderIndexView,
  ZoneNewView,
  Shipping_policyIndexView,
  Shipping_policyEditView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
