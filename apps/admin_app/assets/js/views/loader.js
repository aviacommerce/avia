import MainView    from './main';
import TaxonomyIndexView from './taxonomy/index';
import TaxonomyTaxonomyView from './taxonomy/taxonomy';
import Payment_methodNewView from './payment_method/new';
import ProductProduct_categoryView from './product/product_category';
import ProductEditView from './product/edit';
import OrderIndexView from './order/index';
import ZoneNewView from './zone/new';
import ProductIndexView from './product/index';
import ProductNewView from './product/new';
import DashboardIndexView from './dashboard/index';


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
  DashboardIndexView,
  ProductNewView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
