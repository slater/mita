/*
 * generated by Xtext 2.13.0
 */
package org.eclipse.mita.base.validation

import com.google.inject.Inject
import org.eclipse.mita.base.types.ComplexType
import org.eclipse.mita.base.types.inferrer.ITypeSystemInferrer.InferenceResult
import org.eclipse.mita.base.types.typesystem.ITypeSystem
import org.eclipse.mita.base.types.validation.IValidationIssueAcceptor
import org.eclipse.mita.base.types.validation.IValidationIssueAcceptor.ValidationIssue.Severity

import static org.eclipse.mita.base.types.inferrer.AbstractTypeSystemInferrer.ASSERT_COMPATIBLE
import static org.eclipse.mita.base.types.inferrer.AbstractTypeSystemInferrer.ASSERT_NOT_TYPE
import static org.eclipse.mita.base.types.inferrer.AbstractTypeSystemInferrer.ASSERT_SAME
import static org.eclipse.mita.base.types.inferrer.ITypeSystemInferrer.NOT_COMPATIBLE_CODE
import static org.eclipse.mita.base.types.inferrer.ITypeSystemInferrer.NOT_SAME_CODE
import static org.eclipse.mita.base.types.inferrer.ITypeSystemInferrer.NOT_TYPE_CODE

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class TypeDslValidator extends ExpressionsValidator implements IValidationIssueAcceptor {
	
	public static final String ERROR_WRONG_NUMBER_OF_ARGUMENTS_CODE = "WrongNrOfArgs";
	public static final String ERROR_WRONG_NUMBER_OF_ARGUMENTS_MSG = "Wrong number of arguments, expected %s .";
	
	@Inject
	protected ITypeSystem registry;

	public def assertNotType(InferenceResult currentResult, String msg, IValidationIssueAcceptor acceptor,
			InferenceResult... candidates) {
		if (currentResult == null)
			return;
		for (InferenceResult type : candidates) {
			if (registry.isSame(currentResult.getType(), type.getType())) {
				val result = if(msg != null)  { msg } else { String.format(ASSERT_NOT_TYPE, currentResult) };
				acceptor.accept(new ValidationIssue(Severity.ERROR, result, NOT_TYPE_CODE));
			}
		}
	}

	public def void assertSame(InferenceResult result1, InferenceResult result2, String msg,
			IValidationIssueAcceptor acceptor) {
		if (result1 == null || result2 == null)
			return;
		if (!registry.isSame(result1.getType(), result2.getType())) {
			val result = if(msg != null)  { msg } else { String.format(ASSERT_SAME, result1, result2) };
			acceptor.accept(new ValidationIssue(Severity.ERROR, result, NOT_SAME_CODE));
			return;
		}

		assertTypeBindingsSame(result1, result2, msg, acceptor);
	}

	public def assertCompatible(InferenceResult result1, InferenceResult result2, String msg,
			IValidationIssueAcceptor acceptor) {
		if (result1 == null || result2 == null || isNullOnComplexType(result1, result2)
				|| isNullOnComplexType(result2, result1)) {
			return;
		}
		if (!registry.haveCommonType(result1.getType(), result2.getType())) {
			val result = if(msg != null)  { msg } else { String.format(ASSERT_COMPATIBLE, result1, result2) };
			acceptor.accept(new ValidationIssue(Severity.ERROR, result, NOT_COMPATIBLE_CODE));
			return;
		}
		assertTypeBindingsSame(result1, result2, msg, acceptor);

	}

	public def assertAssignable(InferenceResult varResult, InferenceResult valueResult, String msg,
			IValidationIssueAcceptor acceptor) {
		if (varResult == null || valueResult == null || isNullOnComplexType(varResult, valueResult)) {
			return;
		}
		if (!registry.isSuperType(valueResult.getType(), varResult.getType())) {
			val result = if(msg != null)  { msg } else { String.format(ASSERT_COMPATIBLE, varResult, valueResult) };
			acceptor.accept(new ValidationIssue(Severity.ERROR, result, NOT_COMPATIBLE_CODE));
			return;
		}
		assertTypeBindingsSame(varResult, valueResult, msg, acceptor);
	}

	public def assertTypeBindingsSame(InferenceResult result1, InferenceResult result2, String msg,
			IValidationIssueAcceptor acceptor) {
		val bindings1 = result1.getBindings();
		val bindings2 = result2.getBindings();
		val result = if(msg != null)  { msg } else { String.format(ASSERT_COMPATIBLE, result1, result2); }
		if (bindings1.size() != bindings2.size()) {
			acceptor.accept(new ValidationIssue(Severity.ERROR, result, NOT_COMPATIBLE_CODE));
			return;
		}
		for (var i = 0; i < bindings1.size(); i++) {
			assertSame(bindings1.get(i), bindings2.get(i), msg, acceptor);
		}
	}

	public def assertIsSubType(InferenceResult subResult, InferenceResult superResult, String msg,
			IValidationIssueAcceptor acceptor) {
		if (subResult == null || superResult == null)
			return;
		if (!registry.isSuperType(subResult.getType(), superResult.getType())) {
			val result = if(msg != null)  { msg } else { String.format(ASSERT_COMPATIBLE, subResult, superResult); }
			acceptor.accept(new ValidationIssue(Severity.ERROR, msg, NOT_COMPATIBLE_CODE));
		}
	}

	public def isNullOnComplexType(InferenceResult result1, InferenceResult result2) {
		return result1.getType() instanceof ComplexType
				&& registry.isSame(result2.getType(), registry.getType(ITypeSystem.NULL));
	}
	
	override accept(ValidationIssue issue) {
		switch (issue.getSeverity()) {
		case ERROR: {
			error(issue.getMessage(), null, issue.getIssueCode());			
		}
		case WARNING: {
			warning(issue.getMessage(), null, issue.getIssueCode());			
		}
		case INFO: { }
		}
	}
	
}