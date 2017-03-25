import javax.persistence.criteria {
    CriteriaBuilder,
    CriteriaExpression=Expression
}

//Functions for handling null values:

shared Expression<T?> coalesce<T>(Expression<T?>+ expressions)
        => object satisfies Expression<T?> {
    shared actual function criteriaExpression(
            CriteriaBuilder builder) {
        value [first, *rest] = expressions;
        variable value result = first.criteriaExpression(builder);
        for (next in rest) {
            result = builder.coalesce(result,
                next.criteriaExpression(builder));
        }
        return result;
    }
};

shared Expression<T?> nullIf<T>(Expression<T> expression, Expression<T> val)
        given T satisfies Object
        => object satisfies Expression<T?> {
    suppressWarnings("uncheckedTypeArguments")
    shared actual function criteriaExpression(CriteriaBuilder builder) {
        assert (is CriteriaExpression<Object> x
                = expression.criteriaExpression(builder));
        assert (is CriteriaExpression<Object> y
                = val.criteriaExpression(builder));
        return builder.nullif(x,y);
    }
};

