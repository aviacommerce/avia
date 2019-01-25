import MainView    from './main';
import TaxonomyIndexView from './taxonomy/index';
import TaxonomyTaxonomyView from './taxonomy/taxonomy';
import PaymentMethodNewView from './payment_method/new';
import ProductProductCategoryView from './product/product_category';
import ProductEditView from './product/edit';
import OrderIndexView from './order/index';
import ZoneNewView from './zone/new';
import ProductIndexView from './product/index';
import ProductNewView from './product/new';
import DashboardIndexView from './dashboard/index';
import ShippingPolicyIndexView from './shipping_policy/index'
import ShippingPolicyEditView from './shipping_policy/edit'
import StockLocationNewView from './stock_location/new'
import StockLocationEditView from './stock_location/edit'
import TaxConfigEditView from './tax/tax_config_index'
import TaxClassIndexView from './tax/tax_class_index'

// Collection of specific view modules
const views = {
  TaxonomyIndexView,
  TaxonomyTaxonomyView,
  PaymentMethodNewView,
  ProductProductCategoryView,
  ProductEditView,
  ProductIndexView,
  OrderIndexView,
  ZoneNewView,
  DashboardIndexView,
  ProductNewView,
  StockLocationNewView,
  StockLocationEditView,
  ShippingPolicyIndexView,
  ShippingPolicyEditView,
  TaxConfigEditView,
  TaxClassIndexView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
