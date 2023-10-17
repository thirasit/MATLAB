%%% Luong Attention Function
% The luongAttention function returns the context vector and attention scores according to Luong "general" scoring [1].
% This is equivalent to dot-product attention with queries, keys, and values specified as the hidden state, the weighted latent representation, and the latent representation, respectively.
function [context,attentionScores] = luongAttention(hiddenState,Z,weights)

numHeads = 1;
queries = hiddenState;
keys = pagemtimes(weights,Z);
values = Z;

[context,attentionScores] = attention(queries,keys,values,numHeads, ...
    Scale=1, ...
    DataFormat="CBT");

end
