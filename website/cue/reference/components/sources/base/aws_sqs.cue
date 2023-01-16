package metadata

base: components: sources: aws_sqs: configuration: {
	acknowledgements: {
		description: """
			Controls how acknowledgements are handled by this source.

			This setting is **deprecated** in favor of enabling `acknowledgements` at the [global][global_acks] or sink level. Enabling or disabling acknowledgements at the source level has **no effect** on acknowledgement behavior.

			See [End-to-end Acknowledgements][e2e_acks] for more information on how event acknowledgement is handled.

			[global_acks]: https://vector.dev/docs/reference/configuration/global-options/#acknowledgements
			[e2e_acks]: https://vector.dev/docs/about/under-the-hood/architecture/end-to-end-acknowledgements/
			"""
		required: false
		type: object: options: enabled: {
			description: "Whether or not end-to-end acknowledgements are enabled for this source."
			required:    false
			type: bool: {}
		}
	}
	auth: {
		description: "Configuration of the authentication strategy for interacting with AWS services."
		required:    false
		type: object: options: {
			access_key_id: {
				description: "The AWS access key ID."
				required:    true
				type: string: {}
			}
			assume_role: {
				description: "The ARN of the role to assume."
				required:    true
				type: string: {}
			}
			credentials_file: {
				description: "Path to the credentials file."
				required:    true
				type: string: {}
			}
			imds: {
				description: "Configuration for authenticating with AWS through IMDS."
				required:    false
				type: object: options: {
					connect_timeout_seconds: {
						description: "Connect timeout for IMDS."
						required:    false
						type: uint: {
							default: 1
							unit:    "seconds"
						}
					}
					max_attempts: {
						description: "Number of IMDS retries for fetching tokens and metadata."
						required:    false
						type: uint: default: 4
					}
					read_timeout_seconds: {
						description: "Read timeout for IMDS."
						required:    false
						type: uint: {
							default: 1
							unit:    "seconds"
						}
					}
				}
			}
			load_timeout_secs: {
				description: "Timeout for successfully loading any credentials, in seconds."
				required:    false
				type: uint: {}
			}
			profile: {
				description: "The credentials profile to use."
				required:    false
				type: string: {}
			}
			region: {
				description: """
					The AWS region to send STS requests to.

					If not set, this will default to the configured region
					for the service itself.
					"""
				required: false
				type: string: {}
			}
			secret_access_key: {
				description: "The AWS secret access key."
				required:    true
				type: string: {}
			}
		}
	}
	client_concurrency: {
		description: """
			Number of concurrent tasks to create for polling the queue for messages.

			Defaults to the number of available CPUs on the system.

			Should not typically need to be changed, but it can sometimes be beneficial to raise this value when there is a
			high rate of messages being pushed into the queue and the messages being fetched are small. In these cases,
			System resources may not be fully utilized without fetching more messages per second, as it spends more time
			fetching the messages than processing them.
			"""
		required: false
		type: uint: {}
	}
	decoding: {
		description: "Configures how events are decoded from raw bytes."
		required:    false
		type: object: options: codec: {
			description: "The codec to use for decoding events."
			required:    false
			type: string: {
				default: "bytes"
				enum: {
					bytes: "Uses the raw bytes as-is."
					gelf: """
						Decodes the raw bytes as a [GELF][gelf] message.

						[gelf]: https://docs.graylog.org/docs/gelf
						"""
					json: """
						Decodes the raw bytes as [JSON][json].

						[json]: https://www.json.org/
						"""
					native: """
						Decodes the raw bytes as Vector’s [native Protocol Buffers format][vector_native_protobuf].

						This codec is **[experimental][experimental]**.

						[vector_native_protobuf]: https://github.com/vectordotdev/vector/blob/master/lib/vector-core/proto/event.proto
						[experimental]: https://vector.dev/highlights/2022-03-31-native-event-codecs
						"""
					native_json: """
						Decodes the raw bytes as Vector’s [native JSON format][vector_native_json].

						This codec is **[experimental][experimental]**.

						[vector_native_json]: https://github.com/vectordotdev/vector/blob/master/lib/codecs/tests/data/native_encoding/schema.cue
						[experimental]: https://vector.dev/highlights/2022-03-31-native-event-codecs
						"""
					syslog: """
						Decodes the raw bytes as a Syslog message.

						Will decode either as the [RFC 3164][rfc3164]-style format ("old" style) or the more modern
						[RFC 5424][rfc5424]-style format ("new" style, includes structured data).

						[rfc3164]: https://www.ietf.org/rfc/rfc3164.txt
						[rfc5424]: https://www.ietf.org/rfc/rfc5424.txt
						"""
				}
			}
		}
	}
	delete_message: {
		description: """
			Whether to delete the message once it is processed.

			It can be useful to set this to `false` for debugging or during the initial setup.
			"""
		required: false
		type: bool: default: true
	}
	endpoint: {
		description: "The API endpoint of the service."
		required:    false
		type: string: {}
	}
	framing: {
		description: """
			Framing configuration.

			Framing deals with how events are separated when encoded in a raw byte form, where each event is
			a "frame" that must be prefixed, or delimited, in a way that marks where an event begins and
			ends within the byte stream.
			"""
		required: false
		type: object: options: {
			character_delimited: {
				description:   "Options for the character delimited decoder."
				relevant_when: "method = \"character_delimited\""
				required:      true
				type: object: options: {
					delimiter: {
						description: "The character that delimits byte sequences."
						required:    true
						type: uint: {}
					}
					max_length: {
						description: """
																The maximum length of the byte buffer.

																This length does *not* include the trailing delimiter.
																"""
						required: false
						type: uint: {}
					}
				}
			}
			method: {
				description: "The framing method."
				required:    false
				type: string: {
					default: "bytes"
					enum: {
						bytes:               "Byte frames are passed through as-is according to the underlying I/O boundaries (e.g. split between messages or stream segments)."
						character_delimited: "Byte frames which are delimited by a chosen character."
						length_delimited:    "Byte frames which are prefixed by an unsigned big-endian 32-bit integer indicating the length."
						newline_delimited:   "Byte frames which are delimited by a newline character."
						octet_counting: """
															Byte frames according to the [octet counting][octet_counting] format.

															[octet_counting]: https://tools.ietf.org/html/rfc6587#section-3.4.1
															"""
					}
				}
			}
			newline_delimited: {
				description:   "Options for the newline delimited decoder."
				relevant_when: "method = \"newline_delimited\""
				required:      false
				type: object: options: max_length: {
					description: """
						The maximum length of the byte buffer.

						This length does *not* include the trailing delimiter.
						"""
					required: false
					type: uint: {}
				}
			}
			octet_counting: {
				description:   "Options for the octet counting decoder."
				relevant_when: "method = \"octet_counting\""
				required:      false
				type: object: options: max_length: {
					description: "The maximum length of the byte buffer."
					required:    false
					type: uint: {}
				}
			}
		}
	}
	poll_secs: {
		description: """
			How long to wait while polling the queue for new messages, in seconds.

			Generally should not be changed unless instructed to do so, as if messages are available, they will always be
			consumed, regardless of the value of `poll_secs`.
			"""
		required: false
		type: uint: default: 15
	}
	queue_url: {
		description: "The URL of the SQS queue to poll for messages."
		required:    true
		type: string: {}
	}
	region: {
		description: "The AWS region to use."
		required:    false
		type: string: {}
	}
	tls: {
		description: "TLS configuration."
		required:    false
		type: object: options: {
			alpn_protocols: {
				description: """
					Sets the list of supported ALPN protocols.

					Declare the supported ALPN protocols, which are used during negotiation with peer. Prioritized in the order
					they are defined.
					"""
				required: false
				type: array: items: type: string: examples: ["h2"]
			}
			ca_file: {
				description: """
					Absolute path to an additional CA certificate file.

					The certificate must be in the DER or PEM (X.509) format. Additionally, the certificate can be provided as an inline string in PEM format.
					"""
				required: false
				type: string: examples: ["/path/to/certificate_authority.crt"]
			}
			crt_file: {
				description: """
					Absolute path to a certificate file used to identify this server.

					The certificate must be in DER, PEM (X.509), or PKCS#12 format. Additionally, the certificate can be provided as
					an inline string in PEM format.

					If this is set, and is not a PKCS#12 archive, `key_file` must also be set.
					"""
				required: false
				type: string: examples: ["/path/to/host_certificate.crt"]
			}
			key_file: {
				description: """
					Absolute path to a private key file used to identify this server.

					The key must be in DER or PEM (PKCS#8) format. Additionally, the key can be provided as an inline string in PEM format.
					"""
				required: false
				type: string: examples: ["/path/to/host_certificate.key"]
			}
			key_pass: {
				description: """
					Passphrase used to unlock the encrypted key file.

					This has no effect unless `key_file` is set.
					"""
				required: false
				type: string: examples: ["${KEY_PASS_ENV_VAR}", "PassWord1"]
			}
			verify_certificate: {
				description: """
					Enables certificate verification.

					If enabled, certificates must be valid in terms of not being expired, as well as being issued by a trusted
					issuer. This verification operates in a hierarchical manner, checking that not only the leaf certificate (the
					certificate presented by the client/server) is valid, but also that the issuer of that certificate is valid, and
					so on until reaching a root certificate.

					Relevant for both incoming and outgoing connections.

					Do NOT set this to `false` unless you understand the risks of not verifying the validity of certificates.
					"""
				required: false
				type: bool: {}
			}
			verify_hostname: {
				description: """
					Enables hostname verification.

					If enabled, the hostname used to connect to the remote host must be present in the TLS certificate presented by
					the remote host, either as the Common Name or as an entry in the Subject Alternative Name extension.

					Only relevant for outgoing connections.

					Do NOT set this to `false` unless you understand the risks of not verifying the remote hostname.
					"""
				required: false
				type: bool: {}
			}
		}
	}
	visibility_timeout_secs: {
		description: """
			The visibility timeout to use for messages, in seconds.

			This controls how long a message is left unavailable after it is received. If a message is received, and
			takes longer than `visibility_timeout_secs` to process and delete the message from the queue, it is made available again for another consumer.

			This can happen if there is an issue between consuming a message and deleting it.
			"""
		required: false
		type: uint: default: 300
	}
}