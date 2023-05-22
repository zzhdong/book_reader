/*
 * SMJExpressionNode.m
 *
 * Copyright 2020 Avérous Julien-Pierre
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/filter/ExpressionNode.java */


#import "SMJExpressionNode.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJExpressionNode
*/
#pragma mark - SMJExpressionNode

@implementation SMJExpressionNode


/*
** SMJExpressionNode - SMJPredicate
*/
#pragma mark - SMJExpressionNode - SMJPredicate

- (SMJPredicateApply)applyWithContext:(id <SMJPredicateContext>)context error:(NSError **)error
{
	NSAssert(NO, @"should be overwritten");
	return SMJPredicateApplyError;
}

- (NSString *)stringValue
{
	NSAssert(NO, @"should be overwritten");
	return nil;
}

@end


NS_ASSUME_NONNULL_END
