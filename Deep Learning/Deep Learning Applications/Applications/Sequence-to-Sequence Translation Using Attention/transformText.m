%%% Text Transformation Function
% The transformText function preprocesses and tokenizes the input text for translation by splitting the text into characters and adding start and stop tokens.
% To translate text by splitting the text into words instead of characters, skip the first step.
function documents = transformText(str,startToken,stopToken)

str = strip(replace(str,""," "));
str = startToken + str + stopToken;
documents = tokenizedDocument(str,CustomTokens=[startToken stopToken]);

end