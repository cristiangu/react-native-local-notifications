export function isFunction(value: any): value is Function {
  return value ? typeof value === 'function' : false;
}
